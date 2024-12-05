extends LabObject

func _ready() -> void:
	super()
	$ImagingMenu.hide()
	$ImagingMenu/GelDisplay.close()

func TryActIndependently() -> bool:
	$ImagingMenu.visible = !$ImagingMenu.visible
	if($ImagingMenu.visible):
		$ImagingMenu/GelDisplay.open()
	else:
		$ImagingMenu/GelDisplay.close()
	
	return true

func _on_RichTextLabel_meta_clicked(meta: Variant) -> void:
	OS.shell_open(str(meta))

func _on_CloseButton_pressed() -> void:
	$ImagingMenu.hide()
	$ImagingMenu/GelDisplay.close()

func slot_filled(slot: ObjectSlot, object: LabObject) -> void:
	var filled := false
	if object.is_in_group("Gel Boat"):
		if object.contents != []:
			if object.contents[0].is_in_group("Gel"):
				# TODO (update): This is wonky; see todo in ElectrolysisSetup.gd for an
				# explanation.
				var init_data: Array[Variant] = object.gel_status()
				
				$ImagingMenu/GelDisplay.init(init_data[0], init_data[1])
				$ImagingMenu/GelDisplay.update_bands(object.calculate_positions())
				
				$ImagingMenu.visible = true
				$ImagingMenu/GelDisplay.open()
				object.visible = false
				filled = true
			else:
				print("Container does not contain gel")
				LabLog.Warn('You tried to image a container without a gel in it.')
		else:
			print("Container is empty")
			LabLog.Warn('You tried to image an empty container.')
	else:
		print("Cannot insert this container into gel imager")
		LabLog.Warn('You tried to place a different container into the gel imager instead of the gel boat.')
	if !filled:
		$ObjectSlot.held_object = null
		# Given that an object's active state is set in ObjectSlot, we should reset it to true
		# if the object fails to attach to the slot
		object.active = true

func slot_emptied(slot: ObjectSlot, object: LabObject) -> void:
	object.visible = true
	object.position = Vector2(self.position.x, self.position.y - 150)
	if object.is_in_group("SubsceneManagers"):
		object.HideSubscene()
