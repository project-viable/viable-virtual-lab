extends LabContainer

@export var max_volume: int

var allowed_groups: Array[String] = ["Source Container"]

var default_text: String

var curr_content: SourceContainer

func lab_object_ready() -> void:
	if max_volume == 0:
		print("Warning: Graduated Cylinder has a max volume of 0mL")
	# Initialize volume to 0mL
	var volume: float = 0
	
	$VolumeContainer.set_max_volume(max_volume)
	$VolumeContainer.set_volume(volume)
	
	# Menu hidden by default
	$Menu.hide()
	reset_menu()

func try_interact(others: Array[LabObject]) -> bool:
	for other in others:
		for i in allowed_groups.size():
			if other.is_in_group(allowed_groups[i]):
				# Continue through loop if the graduated cylinder is already full
				if $VolumeContainer.get_volume() == $VolumeContainer.get_max_volume():
					continue
				# Add contents to grad cylinder if it has nothing and the other container has a liquid substance
				# Or if adding more of same liquid substance
				# Set volume of grad cylinder to its max until a menu is created to specify volume
				if len(contents) == 0 and other.check_contents("Liquid Substance").front() \
					or len(contents) > 0 and other.contents.name == contents[0].name:
					$Menu.visible = true
					
					# We want to store the substance in a variable
					# so that it can be accessed in _on_DispenseButton_pressed()
					curr_content = other
					
					# Disable dragging while menu open
					self.draggable = false
					await $Menu/PanelContainer/VBoxContainer/DispenseButton.button_pressed
					# Reenable dragging
					self.draggable = true
				# Other is a container with a liquid substance and grad cylinder already has liquid, so do nothing
				else:
					continue
				update_display()
				print("Graduated cylinder has ", $VolumeContainer.get_volume(), "mL of liquid")
				return true

			elif other.is_in_group("Container"):
				if len(contents) > 0:
					# Check if the other object is active
					if not other.active:
						continue
					# Add contents to container
					# Set grad cylinder volume to 0mL
					other.add_contents(contents)
					contents.clear()
					$VolumeContainer.dump_contents()
					reset_menu()
					update_display()
					LabLog.log("Removed all contents from graduated cylinder.")
					print("Graduated cylinder has ", $VolumeContainer.get_volume(), "mL of liquid")
					return true
				else:
					return false
	return false

func try_act_independently() -> bool:
	return false

func take_contents(volume: float = -1) -> Array[Substance]:
	var content: Array[Substance] = contents.duplicate(true)
	contents.clear()
	$VolumeContainer.dump_contents()
	reset_menu()
	update_display()
	print("Graduated cylinder has ", $VolumeContainer.get_volume(), "mL of liquid")
	return content

func add_contents(new_contents: Array[Substance]) -> void:
	pass

func dispose() -> void:
	contents.clear()
	$VolumeContainer.dump_contents()
	update_display()

func update_display() -> void:
	var max_height: float = $ColorRect.size.y
	var fill_percentage: float = $VolumeContainer.get_volume() / $VolumeContainer.get_max_volume()
	var fill_height: float = max_height * fill_percentage
	$FillProgress.size = Vector2($FillProgress.size.x, fill_height)
	print("Display updated")
	###Now we need to calculate the average color of our contents:
	if len(contents) > 0:
		var r: float = 0
		var g: float = 0
		var b: float = 0
		var volume: float = 0
		
		for content: Substance in contents:
			r += Color(content.color).r * content.volume
			g += Color(content.color).g * content.volume
			b += Color(content.color).b * content.volume
			volume += content.volume
		
		if volume != 0:
			r = r/volume
			g = g/volume
			b = b/volume
		
		$FillProgress.color = Color(r, g, b)
		print("color updated")

# Reset values in menu
func reset_menu() -> void:
	default_text = "Graduated Cylinder currently has a " \
		+ "volume of " + str($VolumeContainer.get_volume()) + "mL"
	$Menu/PanelContainer/VBoxContainer/Description.text = default_text
	$Menu/PanelContainer/VBoxContainer/SpinBox.set_value(0)
	update_display()

func _on_CloseButton_pressed() -> void:
	$Menu.hide()
	reset_menu()

func _on_DispenseButton_pressed() -> void:
	var substance_volume: float = $Menu/PanelContainer/VBoxContainer/SpinBox.value
	if not $VolumeContainer.add_substance(substance_volume):
		$Menu/PanelContainer/VBoxContainer/Description.text = default_text + "\nWarning: Cannot add " \
			+ str(substance_volume) + "mL to container"
	else:
		contents.append_array(curr_content.take_contents($VolumeContainer.get_volume()))
		# Update the volume of the contents
		contents[0].set_volume(substance_volume)
		LabLog.log("Added " + str(contents[0].get_volume()) + "mL of " + contents[0].name + " to graduated cylinder.")
		update_display()
		reset_menu()

func draw() -> void:
	pass
