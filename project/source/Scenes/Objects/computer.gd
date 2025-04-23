extends StaticBody2D

signal channel_select(channel: String)

# These should be set to the connected devices used to adjust the microscope.
@export var joystick: Joystick
@export var focus_control: FocusControl

var is_clicked: bool = false
var zoom_level: String = "None"
var current_slide: String = ""
var delay: int = 0
var brightness: float = 0.0
@onready var cell_image_node: Sprite2D = $%CellImage
@onready var direction:Vector2 = Vector2(0,0)

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
	$PopupControl.hide()
	focus_control.focus_changed.connect(_on_focus_control_focus_changed)

func _process(delta: float) -> void:
	var content_screen:Node2D = $"%ContentScreen"
	if joystick: direction = joystick.get_velocity()
	content_screen.direction = direction

func _on_focus_control_focus_changed(level: float) -> void:
	cell_image_node.material.set("shader_parameter/blur_amount", level)

# Emits a signal to the FlourescenceMicroscope Node, used to zoom into the computer screen
func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	LabLog.log("Entered computer", true, false)
	if event is InputEventMouseButton and event.pressed and not is_clicked:
		$PopupControl.visible = true
		is_clicked = true
		

# Used for exiting the computer
func _on_exit_button_pressed() -> void:
	LabLog.log("Exited computer", true, false)
	get_node("PopupControl").visible = false
	is_clicked = false


func _on_channels_panel_channel_selected(channel: String) -> void:
	LabLog.log("Changed channel to " + channel, false, false)
	current_channel = channel
	channel_select.emit(channel)
	$PopupControl/PanelContainer/VBoxContainer/Screen/ContentScreen/AcquisitonPanel/PowerExposure/PanelLabel.visible = false
	$PopupControl/PanelContainer/VBoxContainer/Screen/ContentScreen/AcquisitonPanel/PowerExposure/GeneralPanel/DapiLabelContainer.visible = false
	$PopupControl/PanelContainer/VBoxContainer/Screen/ContentScreen/AcquisitonPanel/PowerExposure/GeneralPanel/FITCLabelContainer.visible = false
	$PopupControl/PanelContainer/VBoxContainer/Screen/ContentScreen/AcquisitonPanel/PowerExposure/GeneralPanel/TRITCLabelContainer.visible = false
	$PopupControl/PanelContainer/VBoxContainer/Screen/ContentScreen/AcquisitonPanel/PowerExposure/GeneralPanel/Cy5LabelContainer.visible = false
	$PopupControl/PanelContainer/VBoxContainer/Screen/ContentScreen/AcquisitonPanel/PowerExposure/ComboPanel.visible = false
	
	match channel:
		"Combo":
			$PopupControl/PanelContainer/VBoxContainer/Screen/ContentScreen/AcquisitonPanel/PowerExposure/PanelLabel.visible = true
			$PopupControl/PanelContainer/VBoxContainer/Screen/ContentScreen/AcquisitonPanel/PowerExposure/ComboPanel.visible = true
		"Dapi":
			$PopupControl/PanelContainer/VBoxContainer/Screen/ContentScreen/AcquisitonPanel/PowerExposure/PanelLabel.visible = true
			$PopupControl/PanelContainer/VBoxContainer/Screen/ContentScreen/AcquisitonPanel/PowerExposure/GeneralPanel.visible = true
			$PopupControl/PanelContainer/VBoxContainer/Screen/ContentScreen/AcquisitonPanel/PowerExposure/GeneralPanel/DapiLabelContainer.visible = true
			$PopupControl/PanelContainer/VBoxContainer/Screen/ContentScreen/AcquisitonPanel/PowerExposure/GeneralPanel/HBoxContainer4/PowerSlider.value = 75
			$PopupControl/PanelContainer/VBoxContainer/Screen/ContentScreen/AcquisitonPanel/PowerExposure/GeneralPanel/HBoxContainer5/ExposureSlider.value = 1000
		"FITC":
			$PopupControl/PanelContainer/VBoxContainer/Screen/ContentScreen/AcquisitonPanel/PowerExposure/PanelLabel.visible = true
			$PopupControl/PanelContainer/VBoxContainer/Screen/ContentScreen/AcquisitonPanel/PowerExposure/GeneralPanel.visible = true
			$PopupControl/PanelContainer/VBoxContainer/Screen/ContentScreen/AcquisitonPanel/PowerExposure/GeneralPanel/FITCLabelContainer.visible = true
			$PopupControl/PanelContainer/VBoxContainer/Screen/ContentScreen/AcquisitonPanel/PowerExposure/GeneralPanel/HBoxContainer4/PowerSlider.value = 75
			$PopupControl/PanelContainer/VBoxContainer/Screen/ContentScreen/AcquisitonPanel/PowerExposure/GeneralPanel/HBoxContainer5/ExposureSlider.value = 1000

		"TRITC":
			$PopupControl/PanelContainer/VBoxContainer/Screen/ContentScreen/AcquisitonPanel/PowerExposure/PanelLabel.visible = true
			$PopupControl/PanelContainer/VBoxContainer/Screen/ContentScreen/AcquisitonPanel/PowerExposure/GeneralPanel.visible = true
			$PopupControl/PanelContainer/VBoxContainer/Screen/ContentScreen/AcquisitonPanel/PowerExposure/GeneralPanel/TRITCLabelContainer.visible = true
			$PopupControl/PanelContainer/VBoxContainer/Screen/ContentScreen/AcquisitonPanel/PowerExposure/GeneralPanel/HBoxContainer4/PowerSlider.value = 75
			$PopupControl/PanelContainer/VBoxContainer/Screen/ContentScreen/AcquisitonPanel/PowerExposure/GeneralPanel/HBoxContainer5/ExposureSlider.value = 1000

		"Cy5":
			$PopupControl/PanelContainer/VBoxContainer/Screen/ContentScreen/AcquisitonPanel/PowerExposure/PanelLabel.visible = true
			$PopupControl/PanelContainer/VBoxContainer/Screen/ContentScreen/AcquisitonPanel/PowerExposure/GeneralPanel.visible = true
			$PopupControl/PanelContainer/VBoxContainer/Screen/ContentScreen/AcquisitonPanel/PowerExposure/GeneralPanel/Cy5LabelContainer.visible = true
			$PopupControl/PanelContainer/VBoxContainer/Screen/ContentScreen/AcquisitonPanel/PowerExposure/GeneralPanel/HBoxContainer4/PowerSlider.value = 75
			$PopupControl/PanelContainer/VBoxContainer/Screen/ContentScreen/AcquisitonPanel/PowerExposure/GeneralPanel/HBoxContainer5/ExposureSlider.value = 1000


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
	if (current_channel != "Combo"):
		var image_path: String = "res://Images/ImageCells/BPAE/%s/%s/%s.jpg" %[current_slide, current_channel, zoom_level]

		if current_slide == "":
			image_path = "res://Images/ImageCells/EmptySlide.jpg"

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

func _on_content_screen_update_zoom(button_value: String) -> void:
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
		var image_path: String = "res://Images/ImageCells/BPAE/%s/%s/%s.jpg" %[current_slide, channel, zoom_level]
		var img: Image = Image.new()
		var img_resource := ResourceLoader.load(image_path)
		img = img_resource.get_image()
		img.convert(Image.FORMAT_RGBA8)

		opacities_sum += opacity
		images.append({"Image": img, "Opacity" :opacity})
		brightness = max(brightness, opacity)
	
	var compiled_image := Image.create(width, height, false, Image.FORMAT_RGBA8)
	compiled_image.fill(Color(0,0,0,0))
	
	for i in images:
		var img: Image = i["Image"]
		var opacity: float = i["Opacity"] / opacities_sum
		for x in range(width):
			for y in range(height):
				var base_color: Color = compiled_image.get_pixel(x, y)
				var overlay_color: Color = img.get_pixel(x, y)
				overlay_color.a *= opacity
				compiled_image.set_pixel(x, y, base_color.blend(overlay_color))
	
	return compiled_image

func adjust_brightness() -> void:
	var material: ShaderMaterial = cell_image_node.material as ShaderMaterial
	material.set_shader_parameter("brightness", brightness)

