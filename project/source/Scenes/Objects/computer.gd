extends StaticBody2D

signal channel_select(channel: String)

const PAN_SPEED := 500

# These should be set to the connected devices used to adjust the microscope.
@export var joystick: Joystick
@export var focus_control: FocusControl

var is_clicked: bool = false
var zoom_level: String = "None"
var current_slide: DraggableMicroscopeSlide = null
var delay: int = 0
var brightness: float = 0.0

@onready var cell_image_node: TextureRect = $%CellImage
@onready var cell_image_container: Control = $%CellImageContainer

var current_channel : String = ""
# Measures power in percent
# Defaults to 75 for good visibility w/o changing anything
@onready var channels_power: Dictionary = {
	"Dapi": 75.0,
	"FITC": 75.0,
	"TRITC": 75.0,
	"Cy5": 75.0
}
# Measures exposure time in miliseconds
# Defaults to 1000 for good visibility w/o changing anything
@onready var channels_exposure: Dictionary = {
	"Dapi": 1000.0,
	"FITC": 1000.0,
	"TRITC": 1000.0,
	"Cy5": 1000.0
}

func _ready() -> void:
	$Screen.hide()
	$%MicroscopeProgram.hide()
	focus_control.focus_changed.connect(_on_focus_control_focus_changed)

func _process(delta: float) -> void:
	var direction := joystick.get_velocity() if joystick else Vector2.ZERO
	cell_image_node.position -= direction * delta * PAN_SPEED
	cell_image_node.position = cell_image_node.position.clamp(cell_image_container.size - cell_image_node.size, Vector2.ZERO)

func _on_focus_control_focus_changed(level: float) -> void:
	cell_image_node.material.set("shader_parameter/blur_amount", level)

# Emits a signal to the FlourescenceMicroscope Node, used to zoom into the computer screen
func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and not is_clicked:
		LabLog.log("Entered computer", true, false)
		$Screen.show()
		is_clicked = true
		

# Used for exiting the computer
func _on_exit_button_pressed() -> void:
	LabLog.log("Exited computer", true, false)
	$Screen.hide()
	is_clicked = false


func _on_channels_panel_channel_selected(channel: String) -> void:
	LabLog.log("Changed channel to " + channel, false, false)
	current_channel = channel
	channel_select.emit(channel)
	$%PowerExposure/PanelLabel.visible = false
	$%PowerExposure/GeneralPanel/DapiLabelContainer.visible = false
	$%PowerExposure/GeneralPanel/FITCLabelContainer.visible = false
	$%PowerExposure/GeneralPanel/TRITCLabelContainer.visible = false
	$%PowerExposure/GeneralPanel/Cy5LabelContainer.visible = false
	$%PowerExposure/ComboPanel.visible = false
	
	match channel:
		"Combo":
			$%PowerExposure/PanelLabel.visible = true
			$%PowerExposure/ComboPanel.visible = true
		"Dapi":
			$%PowerExposure/PanelLabel.visible = true
			$%PowerExposure/GeneralPanel.visible = true
			$%PowerExposure/GeneralPanel/DapiLabelContainer.visible = true
			$%PowerExposure/GeneralPanel/HBoxContainer4/PowerSlider.value = 75
			$%PowerExposure/GeneralPanel/HBoxContainer5/ExposureSlider.value = 1000
		"FITC":
			$%PowerExposure/PanelLabel.visible = true
			$%PowerExposure/GeneralPanel.visible = true
			$%PowerExposure/GeneralPanel/FITCLabelContainer.visible = true
			$%PowerExposure/GeneralPanel/HBoxContainer4/PowerSlider.value = 75
			$%PowerExposure/GeneralPanel/HBoxContainer5/ExposureSlider.value = 1000

		"TRITC":
			$%PowerExposure/PanelLabel.visible = true
			$%PowerExposure/GeneralPanel.visible = true
			$%PowerExposure/GeneralPanel/TRITCLabelContainer.visible = true
			$%PowerExposure/GeneralPanel/HBoxContainer4/PowerSlider.value = 75
			$%PowerExposure/GeneralPanel/HBoxContainer5/ExposureSlider.value = 1000

		"Cy5":
			$%PowerExposure/PanelLabel.visible = true
			$%PowerExposure/GeneralPanel.visible = true
			$%PowerExposure/GeneralPanel/Cy5LabelContainer.visible = true
			$%PowerExposure/GeneralPanel/HBoxContainer4/PowerSlider.value = 75
			$%PowerExposure/GeneralPanel/HBoxContainer5/ExposureSlider.value = 1000


func _on_exposure_change(new_exposure: float) -> void:
	LabLog.log("Changed exposure to " + str(new_exposure) + "msec for the " + current_channel + " channel", false, false)
	channels_exposure[current_channel] = new_exposure


func _on_power_change(new_power: float) -> void:
	LabLog.log("Changed power to " + str(new_power) + "% for the " + current_channel + " channel", false, false)
	channels_power[current_channel] = new_power


func _on_power_exposure_combo_change(selected_channel: String, attribute: String, value: float) -> void:
	if(attribute == "Power"):
		LabLog.log("Changed power to " + str(value) + "% for the " + selected_channel + " channel in combo", false, false)
		channels_power[selected_channel] = value
	else:
		LabLog.log("Changed exposure to " + str(value) + "msec for the " + selected_channel + " channel in combo", false, false)
		channels_exposure[selected_channel] = value

func _on_play_button_pressed() -> void:
	# check status of slide before processing
	if current_slide == null: 
		var slide_tray: Sprite2D = get_node("../Background/Microscope/microscope_slide_tray")
		if slide_tray.light_on or slide_tray.left_open or slide_tray.right_open:
			LabLog.warn("Ensure the light is turned off and both tray doors are closed")
		# unsure of expected behavior
		return
	elif current_slide != null and not current_slide.slide_orientation_up:
		LabLog.warn("Ensure the slide is facing the correct direction in the slide tray")
		# unsure of expected behavior
		return
	elif current_slide.oiled_up and zoom_level != "100x":
		LabLog.warn("Zoom oil should only be used for 100x magnification")
		# unsure of expected behavior
		return
	elif not current_slide.oiled_up and zoom_level == "100x":
		LabLog.warn("Zoom oil is required for 100x magnification")
		# unsure of expected behavior
		return
	LabLog.log("New image being generated for " + current_channel, false, false)
	if (current_channel != "Combo"):
		var image_path: String = ""
		if current_slide == null:
			image_path = "res://Images/ImageCells/EmptySlide.jpg"
		else:
			image_path = "res://Images/ImageCells/BPAE/%s/%s/%s.jpg" %[current_slide.slide_name, current_channel, zoom_level]


		delay = channels_exposure[current_channel]
		brightness = clamp((calculate_brightness_percentage(current_channel) * 2) - 1, -1.0, 1.0)
		# Delays the visibility of the image based on the miliseconds the user put in
		await get_tree().create_timer((delay/1000)).timeout
		cell_image_node.texture = load(image_path)
		adjust_brightness()
		cell_image_node.visible = true
		return
	var texture := ImageTexture.create_from_image(create_combo_image())
	delay = max(channels_exposure["Dapi"],
				channels_exposure["FITC"],
				channels_exposure["TRITC"],
				channels_exposure["Cy5"])
	# Account for slow image processing
	if(delay - 1000 > 0):
		delay = delay - 1000
	# Delays the visibility of the image based on the miliseconds the user put in
	await get_tree().create_timer((delay/1000)).timeout
	cell_image_node.texture = texture
	brightness = clamp((brightness * 2) - 1, -1.0, 1.0)
	adjust_brightness()
	cell_image_node.visible = true

func _on_macro_panel_button_press(button_value: String) -> void:
	zoom_level = button_value

func calculate_brightness_percentage(channel: String) -> float:
	if(channels_power[channel] != 0.0):
		var power_percent: float = channels_power[channel] / 100.0
		var exposure_percent: float = channels_exposure[channel] / 5000.0
		return (power_percent + exposure_percent) / 2
	return 0.0

func create_combo_image() -> Image:
	var width: int = cell_image_node.texture.get_width()
	var height: int = cell_image_node.texture.get_height()
	var images: Array[Dictionary] = []
	var opacities_sum: float

	for channel: String in channels_power.keys():
		var opacity := calculate_brightness_percentage(channel)
		if (opacity == 0.0):
			continue
		var image_path: String = ""
		if current_slide == null:
			image_path = "res://Images/ImageCells/EmptySlide.jpg"
		else:
			image_path = "res://Images/ImageCells/BPAE/%s/%s/%s.jpg" %[current_slide.slide_name, channel, zoom_level]
		var img: Image = Image.new()
		var img_resource := ResourceLoader.load(image_path)
		img = img_resource.get_image()
		img.convert(Image.FORMAT_RGBA8)

		opacities_sum += opacity
		images.append({"Image": img, "Opacity" :opacity, "Channel": channel})
		brightness = max(brightness, opacity)
	
	var compiled_image := Image.create(width, height, false, Image.FORMAT_RGBA8)
	compiled_image.fill(Color(0,0,0,0))
	
	for i in images:
		var img: Image = i["Image"]
		var opacity: float = i["Opacity"] / opacities_sum
		var rgb_array: Array[float] = get_rgb(i["Channel"])
		var r: float = rgb_array[0]
		var g: float = rgb_array[1]
		var b: float = rgb_array[2]
		for x in range(width):
			for y in range(height):
				var base_color: Color = compiled_image.get_pixel(x, y)
				var overlay_color: Color = img.get_pixel(x, y)
				var intensity: float = max(overlay_color.r, overlay_color.b, overlay_color.g)
				overlay_color = overlay_color.blend(Color(intensity * r, intensity * g, intensity * b,1))
				overlay_color.a *= opacity
				var final_color: Color = base_color.blend(overlay_color)
				final_color.clamp()
				compiled_image.set_pixel(x, y, final_color)
	
	return compiled_image

func adjust_brightness() -> void:
	var material: ShaderMaterial = cell_image_node.material as ShaderMaterial
	material.set_shader_parameter("brightness", brightness)
	if brightness > 0.5:
		LabLog.warn("Overexposing the slide may kill the cells or bleach the dyes")

func get_rgb(channel: String) -> Array[float]:
	if channel == "Dapi":
		return [0,0,1]
	if channel == "FITC":
		return [0,1,0]
	if channel == "TRITC":
		return [1,0,0]
	else:
		return [1,0.75,0.8]

func _on_app_icon_pressed() -> void:
	$%MicroscopeProgram.show()
