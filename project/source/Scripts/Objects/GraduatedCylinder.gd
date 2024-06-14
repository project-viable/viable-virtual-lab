extends LabContainer

export (int) var maxVolume

var allowedGroups = ["Source Container"]

func _ready():
	if maxVolume == 0:
		print("Warning: Graduated Cylinder has a max volume of 0mL")
	# Initialize volume to 0mL
	var volume = 0
	
	$VolumeContainer.SetMaxVolume(maxVolume)
	$VolumeContainer.SetVolume(volume)
	
	# Menu hidden by default
	$Menu.hide()
	ResetMenu()

func TryInteract(others):
	for other in others:
		for i in allowedGroups.size():
			if other.is_in_group(allowedGroups[i]):
				# Add contents to grad cylinder if it has nothing and the other container has a liquid substance
				# Or if adding more of same liquid substance
				# Set volume of grad cylinder to its max until a menu is created to specify volume
				if len(contents) == 0 and other.CheckContents("Liquid Substance") \
				or len(contents) > 0 and other == contents[0]:
					$Menu.visible = true
					var oldVolume = $VolumeContainer.GetVolume()
					
					# Disable dragging while menu open
					self.draggable = false
					yield($Menu/PanelContainer/VBoxContainer/CloseButton, "pressed")
					# Reenable dragging
					self.draggable = true
					# Check if the grad cylinder's substance volume has changed
					if oldVolume != $VolumeContainer.GetVolume() and len(contents) < 1:
						#contents.append(other)
						contents.append_array(other.TakeContents($VolumeContainer.GetVolume()))
						
						# Update the volume of the contents
						contents[0].set_volume($VolumeContainer.GetVolume())
						
				# Other is a container with a liquid substance and grad cylinder already has liquid, so do nothing
				else:
					return false
				print("Graduated cylinder has ", $VolumeContainer.GetVolume(), "mL of liquid")
				return true

			elif other.is_in_group("Container"):
				# Add contents to container
				# Set grad cylinder volume to 0mL
				if len(contents) > 0:
					other.AddContents(contents)
					contents.clear()
					$VolumeContainer.DumpContents()
					ResetMenu()
					print("Graduated cylinder has ", $VolumeContainer.GetVolume(), "mL of liquid")
					return true
				else:
					return false
	return false

func TryActIndependently():
	pass

func TakeContents(volume=-1):
	var content = contents.duplicate(true)
	contents.clear()
	$VolumeContainer.DumpContents()
	ResetMenu()
	print("Graduated cylinder has ", $VolumeContainer.GetVolume(), "mL of liquid")
	return content

func AddContents(new_contents):
	print('add contents')

func dispose():
	contents.clear()
	update_display()

func update_display():
	# static change from "empty" to "filled" for now
	if(len(contents) > 0):
		if(filled_image != null):
			$Sprite.texture = filled_image
	else:
		$Sprite.texture = empty_image
		
# Reset values in menu
func ResetMenu():
	$Menu/PanelContainer/VBoxContainer/Description.text = "Graduated Cylinder currently has a " \
	+ "volume of " + String($VolumeContainer.GetVolume()) + "mL"
	$Menu/PanelContainer/VBoxContainer/SpinBox.set_value(0)

func _on_CloseButton_pressed():
	$Menu.hide()
	ResetMenu()

func _on_DispenseButton_pressed():
	var substanceVolume = $Menu/PanelContainer/VBoxContainer/SpinBox.value
	if not $VolumeContainer.AddSubstance(substanceVolume):
		$Menu/PanelContainer/VBoxContainer/Description.text += "\nWarning: Cannot add " \
		+ String(substanceVolume) + "mL to container"
	else:
		ResetMenu()
