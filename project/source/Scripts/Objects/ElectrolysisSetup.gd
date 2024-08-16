extends LabObject

var fill_substance = null
var current_source = null
var mounted_container = null # This container reference should contain the substance to run

var fill_requested = false

signal menu_closed

var nonfilled_texture = load('res://Images/Resized_Images/Gel_Rig.png')
var filled_texture = load('res://Images/Resized_Images/Gel_Rig_filled_NO_grooves.png')
var filled_wells_texture = load('res://Images/Resized_Images/Gel_Rig_filled.png')
var filled_comb_texture = load('res://Images/Resized_Images/Gel_Rig_comb.png')

func LabObjectReady():
	$GelSimMenu.hide()
	$FollowMenu/SubstanceMenu.hide()

func TryInteract(others):
	for other in others:
		if other.is_in_group("Container") or other.is_in_group("Liquid Container") or other.is_in_group("Source Container"):
			# We need an ionic substance for the electrolysis setup to run
			var ionic_substance = other.CheckContents("Ionic Substance")
			
			if ionic_substance == []:
				return

			if(!(ionic_substance[0])):
				return
			# Open substance menu
			$FollowMenu/SubstanceMenu.visible = true
			
			yield(self, "menu_closed")
			
			if(fill_requested):
				# fill the setup with the container contents
				if(fill_substance == null):
					fill_substance = other.TakeContents()[0]
					$FollowMenu/SubstanceMenu.visible = false
					# Update the Electrolysis setup to show that it is filled
					if mounted_container != null:
						if mounted_container.GelMoldInfo()["hasComb"]:
							$Sprite.texture = filled_comb_texture
						elif mounted_container.GelMoldInfo()["hasWells"]:
							$Sprite.texture = filled_wells_texture
						else:
							$Sprite.texture = filled_texture
					else:
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
		var gelMoldInfo = object.GelMoldInfo()
		mounted_container.visible = false
		
		# Change texture if it has wells
		if gelMoldInfo["hasComb"]:
			$Sprite.texture = filled_comb_texture
		elif gelMoldInfo["hasWells"]:
			$Sprite.texture = filled_wells_texture
		
		var init_data = mounted_container.gel_status()
		$GelSimMenu/GelDisplay.init(init_data[0], init_data[1])
	else:
		slot_emptied(slot, object)

func slot_emptied(slot, object):
	$GelBoatSlot.held_object = null
	if mounted_container == null:
		return
	mounted_container.visible = true
	
	# We should prevent showing the subscene on removing the gel boat
	# as that should be done when the user clicks it, not when removing it
	if mounted_container.is_in_group("SubsceneManagers"):
		mounted_container.HideSubscene();
	
	if fill_substance == null:
		$Sprite.texture = nonfilled_texture
	else:
		$Sprite.texture = filled_texture
		
	mounted_container.position = Vector2(self.position.x - 170, self.position.y - 20)
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
