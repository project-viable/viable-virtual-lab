extends LabContainer

export (int) var maxVolume

var allowedGroups = ["Source Container"]

var DefaultText: String

var CurrContent

func LabObjectReady():
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
				# Continue through loop if the graduated cylinder is already full
				if $VolumeContainer.GetVolume() == $VolumeContainer.GetMaxVolume():
					continue
				# Add contents to grad cylinder if it has nothing and the other container has a liquid substance
				# Or if adding more of same liquid substance
				# Set volume of grad cylinder to its max until a menu is created to specify volume
				if len(contents) == 0 and other.CheckContents("Liquid Substance") \
					or len(contents) > 0 and other.contents.name == contents[0].name:
					$Menu.visible = true
					
					# We want to store the substance in a variable
					# so that it can be accessed in _on_DispenseButton_pressed()
					CurrContent = other
					
					# Disable dragging while menu open
					self.draggable = false
					yield($Menu/PanelContainer/VBoxContainer/DispenseButton, "pressed")
					# Reenable dragging
					self.draggable = true
				# Other is a container with a liquid substance and grad cylinder already has liquid, so do nothing
				else:
					continue
				update_display()
				print("Graduated cylinder has ", $VolumeContainer.GetVolume(), "mL of liquid")
				return true

			elif other.is_in_group("Container"):
				if len(contents) > 0:
					# Check if the other object is active
					if not other.active:
						continue
					# Add contents to container
					# Set grad cylinder volume to 0mL
					other.AddContents(contents)
					contents.clear()
					$VolumeContainer.DumpContents()
					ResetMenu()
					update_display()
					LabLog.Log("Removed all contents from graduated cylinder.")
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
	update_display()
	print("Graduated cylinder has ", $VolumeContainer.GetVolume(), "mL of liquid")
	return content

func AddContents(new_contents):
	pass

func dispose():
	contents.clear()
	$VolumeContainer.DumpContents()
	update_display()

func update_display():
	var maxHeight = $ColorRect.rect_size.y
	var fillPercentage = $VolumeContainer.GetVolume() / $VolumeContainer.GetMaxVolume()
	var fillHeight = maxHeight * fillPercentage
	$FillProgress.rect_size = Vector2($FillProgress.rect_size.x, fillHeight)
	print("Display updated")
	###Now we need to calculate the average color of our contents:
	if len(contents) > 0:
		var r = 0
		var g = 0
		var b = 0
		var volume = 0
		
		for content in contents:
			r += Color(content.color).r * content.volume
			g += Color(content.color).g * content.volume
			b += Color(content.color).b * content.volume
			volume += content.volume
		
		r = r/volume
		g = g/volume
		b = b/volume
		
		$FillProgress.color = Color(r, g, b)
		print("color updated")

# Reset values in menu
func ResetMenu():
	DefaultText = "Graduated Cylinder currently has a " \
		+ "volume of " + String($VolumeContainer.GetVolume()) + "mL"
	$Menu/PanelContainer/VBoxContainer/Description.text = DefaultText
	$Menu/PanelContainer/VBoxContainer/SpinBox.set_value(0)
	update_display()

func _on_CloseButton_pressed():
	$Menu.hide()
	ResetMenu()

func _on_DispenseButton_pressed():
	var substanceVolume = $Menu/PanelContainer/VBoxContainer/SpinBox.value
	if not $VolumeContainer.AddSubstance(substanceVolume):
		$Menu/PanelContainer/VBoxContainer/Description.text = DefaultText + "\nWarning: Cannot add " \
			+ String(substanceVolume) + "mL to container"
	else:
		contents.append_array(CurrContent.TakeContents($VolumeContainer.GetVolume()))
		# Update the volume of the contents
		contents[0].set_volume(substanceVolume)
		LabLog.Log("Added " + str(contents[0].get_volume()) + "mL of " + contents[0].name + " to graduated cylinder.")
		update_display()
		ResetMenu()

func draw():
	pass
