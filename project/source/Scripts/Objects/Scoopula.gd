extends LabContainer

var dispense_mode = 0
var split_substance = [] 

func _ready(): 
	get_node("Menu/PanelContainer/VBoxContainer/DumpButton").pressed = true 
	get_node("Menu/PanelContainer/VBoxContainer/TapButton").disabled = true
	dispense_mode = 1
	$Menu.hide()

func TryInteract(others):
	for other in others:#If interacting with container then we want to dispense or pick up
		if other.is_in_group("Container") or other.is_in_group("Source Container"):
			var granularSubstance = other.CheckContents("Granular Substance")
			if typeof(granularSubstance) == 19:
				if len(granularSubstance) > 0:
					granularSubstance = granularSubstance[0]
			if len(contents) == 0 and granularSubstance:
				# get density to determine volume taken
				var density = other.TakeContents()[0].get_properties()['density']
				contents.append_array(other.TakeContents(0.6 / density)) # roughly 0.6 grams taken
				if(other.is_in_group("Scale")):
					other.UpdateWeight()
				print("Added contents")
				update_display()
				return true
			else:
				if(!contents.empty()):
					if(dispense_mode == 0):#Mode 0 means there is no active mode and a mode needs to be selected
						$Menu.visible = true
						self.draggable = false
						yield($Menu/PanelContainer/VBoxContainer/CloseButton, "pressed")
						self.draggable = true
					elif(dispense_mode == 1):#Mode 1 is dump mode so this adds all of scoopula contents to other container
						other.AddContents(contents)
						print("emptied scoopula")
						contents.clear()
					elif(dispense_mode == 2):#Mode 2 is tap mode so this adds a small amount to outher container
						split_substance.append(SplitContents())
						other.AddContents(split_substance)
						split_substance.clear()
						print("emptied part of scoopula")
					else:
						print("Not dispensing")
				update_display()
				return true
	return false

func SplitContents():
	if(contents.empty()):
		print("empty")
		return null
	else:
		print("array check")
		var split = contents[0].duplicate()
		if(contents[0].get_volume() <= .1/split.get_density()):
			split.set_volume(contents[0].get_volume())
			contents.clear()
			return split
		else:
			print("Prevolume" + str(contents[0].volume))
			split.set_volume(.1/split.get_density()) 
			print("Split volume: " + str(split.volume))
			contents[0].set_volume(contents[0].get_volume() - .1/split.get_density())
			print("After split volume: " + str(contents[0].volume))
		return split

func TryActIndependently():
	$Menu.visible = true
	self.draggable = false
	yield($Menu/PanelContainer/VBoxContainer/CloseButton, "pressed")
	self.draggable = true


func _on_CloseButton_pressed():
	$Menu.hide()

func _on_DumpButton_toggled(button_pressed):
	if(button_pressed == true):
		print(dispense_mode)
		get_node("Menu/PanelContainer/VBoxContainer/TapButton").disabled = true
		dispense_mode = 1
	else:
		get_node("Menu/PanelContainer/VBoxContainer/TapButton").disabled = false
		dispense_mode = 0

func _on_TapButton_toggled(button_pressed):
	if(button_pressed == true):
		print(dispense_mode)
		get_node("Menu/PanelContainer/VBoxContainer/DumpButton").disabled = true
		dispense_mode = 2
	else:
		get_node("Menu/PanelContainer/VBoxContainer/DumpButton").disabled = false
		dispense_mode = 0

func _integrate_forces(state):
	self.rotation_degrees = 39.6
