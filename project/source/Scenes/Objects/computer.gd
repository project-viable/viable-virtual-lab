extends StaticBody2D

signal screen_click_signal()
var is_clicked: bool = false
@onready var joystick:Area2D = $"../Joystick"
@onready var direction:Vector2 = Vector2(0,0)

var current_channel : String = ""
# Measures power in percent
@onready var channels_power: Dictionary = {
	"Dapi": 0.0,
	"FITC": 0.0,
	"TRITC": 0.0,
	"Cy5": 0.0
}
# Measures exposure time in miliseconds
@onready var channels_exposure: Dictionary = {
	"Dapi": 1.0,
	"FITC": 1.0,
	"TRITC": 1.0,
	"Cy5": 1.0
}

func _ready() -> void:
	$PopupControl.hide()
  
func _process(delta: float) -> void:
	var content_screen:Node2D = $"%ContentScreen"
	if joystick: direction = joystick.get_velocity()
	content_screen.direction = direction


# Emits a signal to the FlourescenceMicroscope Node, used to zoom into the computer screen
func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and not is_clicked:
		screen_click_signal.emit()
		is_clicked = true
		

# Used for exiting the computer
func _on_exit_button_pressed() -> void:
	get_node("PopupControl").visible = false
	is_clicked = false


func _on_channels_panel_channel_selected(channel: String) -> void:
	current_channel = channel
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
			$PopupControl/PanelContainer/VBoxContainer/Screen/ContentScreen/AcquisitonPanel/PowerExposure/GeneralPanel/HBoxContainer4/PowerSlider.value = 0
			$PopupControl/PanelContainer/VBoxContainer/Screen/ContentScreen/AcquisitonPanel/PowerExposure/GeneralPanel/HBoxContainer5/ExposureSlider.value = 1
		"FITC":
			$PopupControl/PanelContainer/VBoxContainer/Screen/ContentScreen/AcquisitonPanel/PowerExposure/PanelLabel.visible = true
			$PopupControl/PanelContainer/VBoxContainer/Screen/ContentScreen/AcquisitonPanel/PowerExposure/GeneralPanel.visible = true
			$PopupControl/PanelContainer/VBoxContainer/Screen/ContentScreen/AcquisitonPanel/PowerExposure/GeneralPanel/FITCLabelContainer.visible = true
			$PopupControl/PanelContainer/VBoxContainer/Screen/ContentScreen/AcquisitonPanel/PowerExposure/GeneralPanel/HBoxContainer4/PowerSlider.value = 0
			$PopupControl/PanelContainer/VBoxContainer/Screen/ContentScreen/AcquisitonPanel/PowerExposure/GeneralPanel/HBoxContainer5/ExposureSlider.value = 1
		"TRITC":
			$PopupControl/PanelContainer/VBoxContainer/Screen/ContentScreen/AcquisitonPanel/PowerExposure/PanelLabel.visible = true
			$PopupControl/PanelContainer/VBoxContainer/Screen/ContentScreen/AcquisitonPanel/PowerExposure/GeneralPanel.visible = true
			$PopupControl/PanelContainer/VBoxContainer/Screen/ContentScreen/AcquisitonPanel/PowerExposure/GeneralPanel/TRITCLabelContainer.visible = true
			$PopupControl/PanelContainer/VBoxContainer/Screen/ContentScreen/AcquisitonPanel/PowerExposure/GeneralPanel/HBoxContainer4/PowerSlider.value = 0
			$PopupControl/PanelContainer/VBoxContainer/Screen/ContentScreen/AcquisitonPanel/PowerExposure/GeneralPanel/HBoxContainer5/ExposureSlider.value = 1
		"Cy5":
			$PopupControl/PanelContainer/VBoxContainer/Screen/ContentScreen/AcquisitonPanel/PowerExposure/PanelLabel.visible = true
			$PopupControl/PanelContainer/VBoxContainer/Screen/ContentScreen/AcquisitonPanel/PowerExposure/GeneralPanel.visible = true
			$PopupControl/PanelContainer/VBoxContainer/Screen/ContentScreen/AcquisitonPanel/PowerExposure/GeneralPanel/Cy5LabelContainer.visible = true
			$PopupControl/PanelContainer/VBoxContainer/Screen/ContentScreen/AcquisitonPanel/PowerExposure/GeneralPanel/HBoxContainer4/PowerSlider.value = 0
			$PopupControl/PanelContainer/VBoxContainer/Screen/ContentScreen/AcquisitonPanel/PowerExposure/GeneralPanel/HBoxContainer5/ExposureSlider.value = 1


func _on_exposure_change(new_exposure: float) -> void:
	channels_exposure[current_channel] = new_exposure


func _on_power_change(new_power: float) -> void:
	channels_power[current_channel] = new_power


func _on_power_exposure_combo_change(selected_channel: String, attribute: String, value: float) -> void:
	if(attribute == "Power"):
		channels_power[selected_channel] = value
	else:
		channels_exposure[selected_channel] = value
