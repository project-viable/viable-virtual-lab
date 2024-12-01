extends LabObject
class_name Pipette

@export var min_capacity: float = 1 #microliters
@export var max_capacity: float = 10 #microliters

@export var display_increment_top: float = 10 #microliters
@export var display_increment_middle: float = 1 #microliters
@export var display_increment_bottom: float = 0.1 #microliters
@onready var volume_slider_width: float = display_increment_middle * 2
@onready var volume_slider_step: float = display_increment_bottom

var plunger_press_extent: float = 2 #Stores the lowest value the plunger slider has reached since being reset to the top.
var do_actions: bool = true #used to allow modifying the plunger's state by code without triggering interactions

@export var has_tip: bool = false: set = SetHasTip
@onready var draw_volume: float = snapped((max_capacity - min_capacity)/2, display_increment_bottom): set = SetDrawVolume
var contents: Array[Substance] = [] #current contents
var tip_contaminants: Array[Substance] = [] #stores what the pipette has drawn in since the last time the tip was replaced

func SetHasTip(new_val: bool) -> void:
	has_tip = new_val
	tip_contaminants = []
	
	$BaseSprite.visible = !has_tip
	$TipSprite.visible = has_tip
	
	if has_tip:
		add_to_group("Disposable-Hazard")
	else:
		#If the tip has been removed, and had something in it, whatever was in it is now also gone.
		contents = []
		
		remove_from_group("Disposable-Hazard")

func SetDrawVolume(new_val: float) -> void:
	draw_volume = new_val
	
	if draw_volume < min_capacity:
		LabLog.Warn("Setting this micropipette to a volume lower than its minimum (" + str(min_capacity) + ") could break it!")
	elif draw_volume > max_capacity:
		LabLog.Warn("Setting this micropipette to a volume higher than its maximum (" + str(max_capacity) + ") could break it!")
	
	SetupVolumeDisplay()

func DrawSubstance(from: LabObject, volume_coefficient := 1.0) -> void:
	if has_tip: #Pipette needs a tip to dispense or take in substances
		if len(contents) == 0 and from.CheckContents("Liquid Substance"):
			if(len(tip_contaminants) > 0):
				LabLog.Warn("The pipette tip was already used. If it was for a different substance than this source, dispose the tip and attach a new one to avoid contaminating your substances.")
			contents.append_array(from.TakeContents(draw_volume * volume_coefficient))
			tip_contaminants.append_array(contents)

func DispenseSubstance(to: LabObject) -> void:
	if has_tip and to: #Pipette needs a tip to dispense or take in substances
		to.AddContents(contents)
		ReportAction([self] + contents, "transferSubstance", {'substances': contents})
	
	contents.clear()

#Returns the other object that the pipette should get or send liquid from at the moment
func SelectTarget() -> LabObject:
	var others: Array[LabObject] = GetIntersectingLabObjects()
	
	for other in others:
		if (other.is_in_group("Container") or other.is_in_group("Source Container")) and (
			other.GetSubsceneManagerParent() == GetSubsceneManagerParent()
		):
			return other
	
	return null

func LabObjectReady() -> void:
	$TipSprite.hide()
	HideMenu()

func TryInteract(others: Array[LabObject]) -> bool:
	for other in others:
		if other.is_in_group("Container") or other.is_in_group("Source Container"):
			ShowMenu()
			return true
		elif other.is_in_group("Tip Box"):
			SetHasTip(true)
			return true
	
	return false

func TryActIndependently() -> bool:
	ShowMenu()
	return true

func dispose() -> void:
	if(has_tip): #If the pipette has a tip, remove it.
		SetHasTip(false)
		LabLog.Log("Ejected Pipette Tip.", false, true)
	else: #If there is no tip, the user is attempting to throw away the pipette itself
		self.queue_free()

func ShowMenu() -> void:
	$Menu.show()
	$Menu/Border/PlungerSlider.value = 2
	
	SetupVolumeSlider()
	$Menu/Border/VolumeSlider.value = draw_volume #this is not in SetupVolumeSlider() so we don't create a loop with the signal
	
	SetupVolumeDisplay()
	
	$Menu/Border/ActionLabel.text = ""
	
	do_actions = true

func HideMenu() -> void:
	$Menu/Border/ActionLabel.text = ""
	$Menu.hide()

func SetupVolumeSlider() -> void:
	$Menu/Border/VolumeSlider.step = volume_slider_step
	$Menu/Border/VolumeSlider.min_value = draw_volume - (volume_slider_width/2)
	$Menu/Border/VolumeSlider.max_value = draw_volume + (volume_slider_width/2)

func SetupVolumeDisplay() -> void:
	var remaining := draw_volume
	$Menu/Border/VolumeDialLabels/Top.text = str(int(remaining/display_increment_top))
	remaining = fmod(remaining, display_increment_top)
	$Menu/Border/VolumeDialLabels/Middle.text = str(int(remaining/display_increment_middle))
	remaining = fmod(remaining, display_increment_middle)
	$Menu/Border/VolumeDialLabels/Bottom.text = str(int(remaining/display_increment_bottom))

func _on_CloseButton_pressed() -> void:
	HideMenu()

func _on_EjectTipButton_pressed() -> void:
	SetHasTip(false)
	$Menu/Border/ActionLabel.text = "Ejected Tip!"
	$Menu/AutoCloseTimer.start()

func _on_VolumeSlider_value_changed(value: float) -> void:
	SetDrawVolume(value)

func _on_VolumeSlider_drag_ended(value_changed: bool) -> void:
	SetupVolumeSlider()

func _on_PlungerSlider_value_changed(value: float) -> void:
	if plunger_press_extent > value:
		plunger_press_extent = value
	
	if do_actions:
		if value == 0:
			#all the way down
			if len(contents) > 0:
				DispenseSubstance(SelectTarget())
				do_actions = false #reenabled when the menu is shown again.
				$Menu/Border/ActionLabel.text = "Dispensed contents!"
				$Menu/AutoCloseTimer.start()
		elif value == 2 and len(contents) == 0:
			#just ended a plunger press while empty
			
			var draw_factor: float
			if plunger_press_extent == 1:
				#just ended a half press while empty
				draw_factor = 1.0
			elif plunger_press_extent == 0:
				#just ended a full press while empty
				#so we draw a little extra.
				draw_factor = 1.25
				LabLog.Warn("The plunger should be pressed to the first stop to draw substances in. Using the second stop will cause it to draw more than the intended amount.")
			
			var other_object := SelectTarget()
			if other_object:
				DrawSubstance(other_object, draw_factor)
				do_actions = false #reenabled when the menu is shown again.
				$Menu/Border/ActionLabel.text = "Drew " + str(draw_volume * draw_factor) + "uL!"
				$Menu/AutoCloseTimer.start()
	
	#finally:
	if value == 2:
		#We've reset the plunger to the top, so anything that happens in the future is a different press of the button.
		plunger_press_extent = 2

func _on_PlungerSlider_drag_ended(value_changed: bool) -> void:
	#Make the plunger spring back
	if $Menu/Border/PlungerSlider.value == 1 and plunger_press_extent == 1:
		#It has just been released, it's half pressed, and it was previously not pressed at all
		#That^ means we've just half pressed and released
		#So we go ahead and make it go back up
		$Menu/Border/PlungerSlider.value = 2 #This does trigger the slider's value_changed signal.
	
	if $Menu/Border/PlungerSlider.value == 0:
		#similar to above
		$Menu/Border/PlungerSlider.value = 2

func _on_AutoCloseTimer_timeout() -> void:
	#Make it exactly the same as if you hit the X:
	_on_CloseButton_pressed()
