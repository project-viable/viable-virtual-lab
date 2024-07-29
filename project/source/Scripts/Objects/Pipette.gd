extends LabObject
class_name Pipette

export var minCapacity: float = 1 #microliters
export var maxCapacity: float = 10 #microliters

export var displayIncrementTop: float = 10 #microliters
export var displayIncrementMiddle: float = 1 #microliters
export var displayIncrementBottom: float = 0.1 #microliters
onready var volumeSliderWidth = displayIncrementMiddle * 2
onready var volumeSliderStep = displayIncrementBottom

onready var plungerPressExtent = 2 #Stores the lowest value the plunger slider has reached since being reset to the top.

export var hasTip: bool = false setget SetHasTip
onready var drawVolume: float = stepify((maxCapacity - minCapacity)/2, displayIncrementBottom) setget SetDrawVolume #microliters. onready set to the halfway point, rounded to the nearest unit the display can show.
var contents = [] #current contents
var tipContaminants = [] #stores what the pipette has drawn in since the last time the tip was replaced

func SetHasTip(newVal):
	hasTip = newVal
	tipContaminants = []
	
	$BaseSprite.visible = !hasTip
	$TipSprite.visible = hasTip
	
	if !hasTip:
		#If the tip has been removed, and had something in it, whatever was in it is now also gone.
		contents = []

func SetDrawVolume(newVal):
	drawVolume = newVal
	
	if drawVolume < minCapacity:
		LabLog.Warn("Setting this micropipette to a volume lower than its minimum (" + str(minCapacity) + ") could break it!")
	elif drawVolume > maxCapacity:
		LabLog.Warn("Setting this micropipette to a volume higher than its maximum (" + str(maxCapacity) + ") could break it!")
	
	SetupVolumeDisplay()

func DrawSubstance(from: LabObject):
	if hasTip: #Pipette needs a tip to dispense or take in substances
		if len(contents) == 0 and from.CheckContents("Liquid Substance"):
			if(len(tipContaminants) > 0):
				LabLog.Warn("The pipette tip was already used. If it was for a different substance than this source, dispose the tip and attach a new one to avoid contaminating your substances.")
			contents.append_array(from.TakeContents(drawVolume))
			tipContaminants.append_array(contents)

func DispenseSubstance(to: LabObject):
	if hasTip and to: #Pipette needs a tip to dispense or take in substances
		to.AddContents(contents)
		ReportAction([self] + contents, "transferSubstance", {'substances': contents})
	
	contents.clear()

#Returns the other object that the pipette should get or send liquid from at the moment
func SelectTarget():
	var others = GetIntersectingLabObjects()
	
	for other in others:
		if (other.is_in_group("Container") or other.is_in_group("Source Container")) and (
			other.GetSubsceneManagerParent() == GetSubsceneManagerParent()
		):
			return other
	
	return null

func LabObjectReady():
	HideMenu()

func TryInteract(others):
	for other in others:
		if other.is_in_group("Container") or other.is_in_group("Source Container"):
			ShowMenu()
			return true
		elif other.is_in_group("Tip Box"):
			SetHasTip(true)
			return true
	
	return false

func TryActIndependently():
	ShowMenu()
	return true

func dispose():
	if(hasTip): #If the pipette has a tip, remove it.
		SetHasTip(false)
	else: #If there is no tip, the user is attempting to throw away the pipette itself
		self.queue_free()

func ShowMenu():
	$Menu.show()
	$Menu/Border/PlungerSlider.value = 2
	
	SetupVolumeSlider()
	$Menu/Border/VolumeSlider.value = drawVolume #this is not in SetupVolumeSlider() so we don't create a loop with the signal
	
	SetupVolumeDisplay()
	
	$Menu/Border/ActionLabel.text = ""

func HideMenu():
	$Menu/Border/ActionLabel.text = ""
	$Menu.hide()

func SetupVolumeSlider():
	$Menu/Border/VolumeSlider.step = volumeSliderStep
	$Menu/Border/VolumeSlider.min_value = drawVolume - (volumeSliderWidth/2)
	$Menu/Border/VolumeSlider.max_value = drawVolume + (volumeSliderWidth/2)

func SetupVolumeDisplay():
	var remaining = drawVolume
	$Menu/Border/VolumeDialLabels/Top.text = str(int(remaining/displayIncrementTop))
	remaining = fmod(remaining, displayIncrementTop)
	$Menu/Border/VolumeDialLabels/Middle.text = str(int(remaining/displayIncrementMiddle))
	remaining = fmod(remaining, displayIncrementMiddle)
	$Menu/Border/VolumeDialLabels/Bottom.text = str(int(remaining/displayIncrementBottom))

func _on_CloseButton_pressed():
	HideMenu()

func _on_EjectTipButton_pressed():
	SetHasTip(false)
	$Menu/Border/ActionLabel.text = "Ejected Tip!"
	$Menu/AutoCloseTimer.start()

func _on_VolumeSlider_value_changed(value):
	SetDrawVolume(value)

func _on_VolumeSlider_drag_ended(value_changed):
	SetupVolumeSlider()

func _on_PlungerSlider_value_changed(value):
	if plungerPressExtent > value:
		plungerPressExtent = value
	
	if value == 0:
		#all the way down
		if len(contents) > 0:
			DispenseSubstance(SelectTarget())
			$Menu/Border/ActionLabel.text = "Dispensed contents!"
			$Menu/AutoCloseTimer.start()
	elif value == 2 and plungerPressExtent == 1:
		#just ended a half press
		var otherObject = SelectTarget()
		if otherObject:
			DrawSubstance(otherObject)
			$Menu/Border/ActionLabel.text = "Drew " + str(drawVolume) + "uL!"
			$Menu/AutoCloseTimer.start()
	
	if value == 2:
		#We've reset the plunger to the top, so anything that happens in the future is a different press of the button.
		plungerPressExtent = 2

func _on_PlungerSlider_drag_ended(value_changed):
	#Make the plunger spring back
	if $Menu/Border/PlungerSlider.value == 1 and plungerPressExtent == 1:
		#It has just been released, it's half pressed, and it was previously not pressed at all
		#That^ means we've just half pressed and released
		#So we go ahead and make it go back up
		$Menu/Border/PlungerSlider.value = 2 #This does trigger the slider's value_changed signal.
		

func _on_AutoCloseTimer_timeout():
	#Make it exactly the same as if you hit the X:
	_on_CloseButton_pressed()
