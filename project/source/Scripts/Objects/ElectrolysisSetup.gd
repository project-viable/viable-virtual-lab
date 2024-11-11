extends LabObject

var fill_substance: Substance = null

# TODO (update): This is treated as if it should hold a reference to some object, but it's set to
# `true` in `ElectrodeTerminal.gd`. Either the external code should be modified to treat this
# exclusively as `bool`, or it should be changed to some reference type and treated as such. The
# latter might be worth doing if this class might eventually want to access the current source (I
# assume this refers to the object supplying the current).
var current_source: bool = null
var mounted_container: GelMoldSubsceneManager = null # This container reference should contain the substance to run

var fill_requested := false

signal menu_closed

var nonfilled_texture: Texture2D = load('res://Images/Resized_Images/Gel_Rig.png')
var filled_texture: Texture2D = load('res://Images/Resized_Images/Gel_Rig_filled_NO_grooves.png')
var filled_wells_texture: Texture2D = load('res://Images/Resized_Images/Gel_Rig_filled.png')
var filled_comb_texture: Texture2D = load('res://Images/Resized_Images/Gel_Rig_comb.png')

func LabObjectReady() -> void:
	$GelSimMenu.hide()
	$FollowMenu/SubstanceMenu.hide()

func TryInteract(others: Array[LabObject]) -> void:
	if fill_substance:
		return
	for other in others:
		if other.is_in_group("Container") or other.is_in_group("Liquid Container") or other.is_in_group("Source Container"):
			# We need an ionic substance for the electrolysis setup to run
			var ionic_substance: Array[bool] = other.CheckContents("Ionic Substance")
			
			if ionic_substance == []:
				return

			if(!(ionic_substance[0])):
				return

			# Open substance menu
			$FollowMenu/SubstanceMenu.visible = true
			
			await self.menu_closed
			
			if(fill_requested):
				# fill the setup with the container contents
				fill_substance = other.TakeContents()[0]
				$FollowMenu/SubstanceMenu.visible = false
				# Update the Electrolysis setup to show that it is filled
				$Sprite2D.texture = filled_texture
				if mounted_container != null:
					if mounted_container.GelMoldInfo()["hasComb"]:
						$Sprite2D.texture = filled_comb_texture
					elif mounted_container.GelMoldInfo()["hasWells"]:
						$Sprite2D.texture = filled_wells_texture
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

func run_current(voltage: float, time: float, print_text := false) -> void:
	if able_to_run_current((print_text)):
		# run current through the container
		mounted_container.run_current(voltage, time)
		
		# update the gel display
		var content: LabObject = $ObjectSlot.get_object()
		if(content != null):
			if(content.is_in_group('Gel Boat')):
				$GelSimMenu/GelDisplay.update_bands(content.calculate_positions())
		
		if(!$GelSimMenu.visible):
			$GelSimMenu.visible = true
			$GelSimMenu/GelDisplay.open()

func terminal_connected(terminal: LabObject, contact: LabObject) -> bool:
	return $PosTerminal.connected() || $NegTerminal.connected()

func slot_filled(slot: ObjectSlot, object: LabObject) -> void:
	if(object.is_in_group('Gel Boat')):
		mounted_container = object
		var gelMoldInfo := object.GelMoldInfo()
		mounted_container.visible = false
		
		# Change texture if it has wells
		if gelMoldInfo["hasComb"]:
			$Sprite2D.texture = filled_comb_texture
		elif gelMoldInfo["hasWells"]:
			$Sprite2D.texture = filled_wells_texture
		
		# TODO (update): `gel_status` returns an array in the form [m, w] where m is a
		# `GelMoldSubsceneManager` (equal to `mounted_container`) and w is a `bool`. This can
		# probably just be changed to return `bool` and `init` here can be called as
		# `init(mounted_container, init_data)`.
		var init_data := mounted_container.gel_status()
		$GelSimMenu/GelDisplay.init(init_data[0], init_data[1])
	else:
		slot_emptied(slot, object)

func slot_emptied(slot: ObjectSlot, object: LabObject) -> void:
	$ObjectSlot.held_object = null
	if mounted_container == null:
		return
	mounted_container.visible = true
	
	# We should prevent showing the subscene on removing the gel boat
	# as that should be done when the user clicks it, not when removing it
	if mounted_container.is_in_group("SubsceneManagers"):
		mounted_container.HideSubscene();
	
	if fill_substance == null:
		$Sprite2D.texture = nonfilled_texture
	else:
		$Sprite2D.texture = filled_texture
		
	mounted_container.position = Vector2(self.position.x - 170, self.position.y - 20)
	mounted_container = null

func _on_SubstanceCloseButton_pressed() -> void:
	$FollowMenu/SubstanceMenu.visible = false
	emit_signal("menu_closed")

func _on_FillButton_pressed() -> void:
	fill_requested = true
	emit_signal("menu_closed")

func _on_CloseButton_pressed() -> void:
	$GelSimMenu.visible = false
	$GelSimMenu/GelDisplay.close()
