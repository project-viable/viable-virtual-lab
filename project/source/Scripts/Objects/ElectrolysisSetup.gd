extends LabObject

var fill_substance: Substance = null

# Container currently being used to fill the setup.
var current_container: LabObject = null

var has_current_source: bool = false
var mounted_container: GelMoldSubsceneManager = null # This container reference should contain the substance to run

var nonfilled_texture: Texture2D = load('res://Images/Resized_Images/Gel_Rig.png')
var filled_texture: Texture2D = load('res://Images/Resized_Images/Gel_Rig_filled_NO_grooves.png')
var filled_wells_texture: Texture2D = load('res://Images/Resized_Images/Gel_Rig_filled.png')
var filled_comb_texture: Texture2D = load('res://Images/Resized_Images/Gel_Rig_comb.png')

func lab_object_ready() -> void:
	$GelSimMenu.hide()
	$FollowMenu/SubstanceMenu.hide()

func try_interact(others: Array[LabObject]) -> bool:
	if fill_substance:
		return false

	for other in others:
		if other.is_in_group("Container") or other.is_in_group("Liquid Container") or other.is_in_group("Source Container"):
			current_container = other
			# Open substance menu
			$FollowMenu/SubstanceMenu.visible = true

			return true

	return false

func able_to_run_current(print_text: bool = false) -> bool:
	if(!has_current_source || !$PosTerminal.connected() || !$NegTerminal.connected()):
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

		if(!$GelSimMenu.visible):
			$GelSimMenu.visible = true
			$GelSimMenu/GelDisplay.open()

		# update the gel display
		var content: LabObject = $ObjectSlot.get_object()
		if(content != null):
			if(content.is_in_group('Gel Boat')):
				$GelSimMenu/GelDisplay.update_bands(content.calculate_positions())

func terminal_connected(terminal: LabObject, contact: LabObject) -> bool:
	return $PosTerminal.connected() || $NegTerminal.connected()

func slot_filled(slot: ObjectSlot, object: LabObject) -> void:
	if(object.is_in_group('Gel Boat')):
		mounted_container = object
		var gel_mold_info: Dictionary = object.gel_mold_info()
		mounted_container.visible = false

		# Change texture if it has wells
		if gel_mold_info["hasComb"]:
			$Sprite2D.texture = filled_comb_texture
		elif gel_mold_info["hasWells"]:
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
		mounted_container.hide_subscene();

	if fill_substance == null:
		$Sprite2D.texture = nonfilled_texture
	else:
		$Sprite2D.texture = filled_texture

	mounted_container.position = Vector2(self.position.x - 170, self.position.y - 20)
	mounted_container = null

func _on_SubstanceCloseButton_pressed() -> void:
	$FollowMenu/SubstanceMenu.visible = false

func _on_FillButton_pressed() -> void:
	if not current_container: return

	# We need an ionic substance for the electrolysis setup to run
	var ionic_substance: Array[bool] = current_container.check_contents("Ionic Substance")

	if(len(ionic_substance) == 0 or not ionic_substance.front()):
		return

	# fill the setup with the container contents
	fill_substance = current_container.take_contents()[0]

	$FollowMenu/SubstanceMenu.visible = false
	# Update the Electrolysis setup to show that it is filled
	$Sprite2D.texture = filled_texture
	if mounted_container != null:
		if mounted_container.gel_mold_info()["hasComb"]:
			$Sprite2D.texture = filled_comb_texture
		elif mounted_container.gel_mold_info()["hasWells"]:
			$Sprite2D.texture = filled_wells_texture
	elif(current_container.check_contents("Liquid Substance")):
		print('The setup is already filled.')
	else:
		print('The setup cannot be filled with that.')

func _on_CloseButton_pressed() -> void:
	$GelSimMenu.visible = false
	$GelSimMenu/GelDisplay.close()
