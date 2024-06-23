extends LabObject

export var minCapacity: float #microliters
export var maxCapacity: float #microliters

export var displayIncrementTop: float #microliters
export var displayIncrementMiddle: float #microliters
export var displayIncrementBottom: float #microliters

export var hasTip: bool = false setget SetHasTip
var drawVolume: float #microliters
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

func DrawSubstance(from: LabObject):
	if hasTip: #Pipette needs a tip to dispense or take in substances
		if len(contents) == 0 and from.CheckContents("Liquid Substance"):
			if(len(tipContaminants) > 0):
				LabLog.Warn("The pipette tip was already used. If it was for a different substance than this source, dispose the tip and attach a new one to avoid contaminating your substances.")
			contents.append_array(from.TakeContents(drawVolume))
			tipContaminants.append_array(contents)

func DispenseSubstance(to: LabObject):
	if hasTip: #Pipette needs a tip to dispense or take in substances
		to.AddContents(contents)
		contents.clear()

func TryInteract(others):
	for other in others:
		if other.is_in_group("Container") or other.is_in_group("Source Container"):
			#TODO: Open the menu
			return true
		elif other.is_in_group("Tip Box"):
			SetHasTip(true)
			return true
	
	return false

func TryActIndependently():
	#Show popup
	pass

func dispose():
	if(hasTip): #If the pipette has a tip, remove it.
		SetHasTip(false)
	else: #If there is no tip, the user is attempting to throw away the pipette itself
		self.queue_free()
