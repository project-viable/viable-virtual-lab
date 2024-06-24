extends LabObject

var fill_substance = null
var current_source = null
var mounted_container = null # This container reference should contain the substance to run

var fill_requested = false

signal menu_closed

var filled_texture = load('res://Images/Gel_Rig_filled.png')

func TryInteract(others):
	for other in others:
		if other.is_in_group("Container") or other.is_in_group("Source Container"):
			var liquid_substance = other.CheckContents("Liquid Substance")
			if len(liquid_substance) > 1:
				liquid_substance = liquid_substance[0]
			if(!(liquid_substance[0])):
				return
			# Open substance menu
			$FollowMenu/SubstanceMenu.visible = true
			
			yield(self, "menu_closed")
			
			if(fill_requested):
				# fill the setup with the container contents
				if(fill_substance == null):
					fill_substance = other.TakeContents()[0]
					print(fill_substance)
					$FollowMenu/SubstanceMenu.visible = false
					# Update the Electrolysis setup to show that it is filled
					$Sprite.texture = filled_texture
				elif(other.CheckContents("Liquid Substance")):
					print('The setup is already filled.')
				else:
					print('The setup cannot be filled with that.')
				
				fill_requested = false

func able_to_run_current(print_text: bool = false) -> bool:
	if(current_source == null || !$PosTerminal.connected() || !$NegTerminal.connected()):
		if print_text:
			print('There is no current source attached.')
		return false
	if(fill_substance == null || !fill_substance.is_in_group('Conductive')):
		if print_text:
			print('The conducting fill is either missing or non-conductive.')
		return false
	if(mounted_container == null || !mounted_container.is_in_group('Conductive')):
		if print_text:
			print('Running an empty or non-conductive setup...')
		return false
	return true

func run_current(voltage, time, print_text = false):
	if able_to_run_current((print_text)):
		# run current through the container
		mounted_container.run_current(voltage, time)
		
		# update the gel display
		var content = $GelBoatSlot.get_object()
		if(content != null):
			if(content.is_in_group('Gel Boat')):
				$GelSimMenu/GelDisplay.update_bands(content.calculate_positions())
		
		if(!$GelSimMenu.visible):
			$GelSimMenu.visible = true
			$GelSimMenu/GelDisplay.open()

func terminal_connected(terminal, contact):
	return $PosTerminal.connected() || $NegTerminal.connected()

func slot_filled(slot, object):
	if(object.is_in_group('Gel Boat')):
		mounted_container = object
		mounted_container.visible = false
		var init_data = mounted_container.gel_status()
		$GelSimMenu/GelDisplay.init(init_data[0], init_data[1])

func slot_emptied(slot, object):
	if mounted_container == null:
		return
	mounted_container.visible = true
	mounted_container = null

func _on_SubstanceCloseButton_pressed():
	$FollowMenu/SubstanceMenu.visible = false
	emit_signal("menu_closed")

func _on_FillButton_pressed():
	fill_requested = true
	emit_signal("menu_closed")

func _on_CloseButton_pressed():
	$GelSimMenu.visible = false
	$GelSimMenu/GelDisplay.close()
