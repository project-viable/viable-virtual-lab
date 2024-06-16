extends LabObject

var contents = []

var minVolume = 0.002
var maxVolume = 0.02
var drawVolume = (minVolume + maxVolume) / 2
var drawIncrement = 0.0001
var drawFastIncrement = 0.001
var temp = 0.0
var hasTip = false
var isContaminated = false

func _ready():
	$Menu.hide()
	#print_tree_pretty()
	$SubsceneManager.subscene = $SubsceneManager/Subscene2
	#add_to_group("SubsceneManagers", true)
	#$SubsceneManager.subscene.z_index = VisualServer.CANVAS_ITEM_Z_MAX #to make this subscene draw above ones above it in the tree
	#if not Engine.editor_hint: $SubsceneManager.HideSubscene()

func TryInteract(others):
	for other in others:
		if other.is_in_group("Container") or other.is_in_group("Source Container"):
			if hasTip: #Pipette needs a tip to dispense or take in substances
				if len(contents) == 0 and other.CheckContents("Liquid Substance"):
					if(isContaminated):
						LabLog.Warn("The pipette tip was already used. If it was for a different substance than this source, dispose the tip and attach a new one to avoid contaminating your substances.")
					contents.append_array(other.TakeContents(drawVolume))
					isContaminated = true
				elif len(contents) > 0:
					currentScene.PipetteDispenseChecker([contents])
					other.AddContents(contents)
					contents.clear()
			else:
				LabLog.Warn("Attempted to use pipette without a pipette tip", false, false)
			return true
		elif other.is_in_group("Tip Box"):
			hasTip = true
			$Sprite.texture = load("res://Images/PipetteYesTip (3).png")
			return true
	
	return false

func TryActIndependently():
	#$Menu.visible = !$Menu.visible #show popup menu
	temp = drawVolume
	$SubsceneManager.TryActIndependently()
	$SubsceneManager/Subscene2/Label.text = str(temp * 1000).pad_decimals(1)


func _on_Submit_pressed():
	temp = $Menu/PanelContainer/VBoxContainer/LineEdit.text
	temp = temp.to_float()
	if (temp < minVolume):
		temp = minVolume
	if (temp > maxVolume):
		temp = maxVolume
	drawVolume = temp / 1000
	print("Draw volume = " + str(drawVolume))
	$Menu.hide()


func _on_Cancel_pressed():
	#$Menu.hide()
	$SubsceneManager.HideSubscene()

func dispose():
	if(hasTip):#If the pipette has a tip, remove it, change the texture to the no-tip version, and empty contents
		hasTip = false
		isContaminated = false
		$Sprite.texture = load("res://Images/Pipette_20.png")
		contents = []
	else: #If there is no tip, the user is attempting to throw away the pipette itself
		self.queue_free()


func _on_Confirm_pressed():
	drawVolume = temp
	print("Draw Volume: " + str(drawVolume))
	$SubsceneManager.HideSubscene()


func _on_VolumeUp_pressed():
	temp += drawIncrement
	if(temp > maxVolume): temp = maxVolume
	$SubsceneManager/Subscene2/Label.text = str(temp * 1000).pad_decimals(1)


func _on_VolumeDown_pressed():
	temp -= drawIncrement
	if(temp < minVolume): temp = minVolume
	$SubsceneManager/Subscene2/Label.text = str(temp * 1000).pad_decimals(1)


func _on_VolumeFastUp_pressed():
	temp += drawFastIncrement
	if(temp > maxVolume): temp = maxVolume
	$SubsceneManager/Subscene2/Label.text = str(temp * 1000).pad_decimals(1)


func _on_VolumeFastDown_pressed():
	temp -= drawFastIncrement
	if(temp < minVolume): temp = minVolume
	$SubsceneManager/Subscene2/Label.text = str(temp * 1000).pad_decimals(1)
