extends LabBody
class_name PowerSupply

# For simplicity sake, these will only toggle when the wire matches the outlet
# It is technically possible to mismatch on both the power supply and gel rig and
# the experiment will run just fine
@export var positive_connected: bool = false
@export var negative_connected: bool = false
@export var increment_time_button: TextureButton
@export var decrement_time_button: TextureButton
@export var increment_volts_button: TextureButton
@export var decrement_volts_button: TextureButton
@export var time_line_edit: LineEdit
@export var voltage_line_edit: LineEdit

@onready var button_function_dict: Dictionary = {
	increment_time_button: {
		"function": increment_time,
		"type": ConfigType.TIME,
	},
	decrement_time_button: {
		"function": decrement_time,
		"type": ConfigType.TIME,
	},
	increment_volts_button: {
		"function": increment_volts,
		"type": ConfigType.VOLT,
	},
	decrement_volts_button: {
		"function": decrement_volts,
		"type": ConfigType.VOLT,
	},
}

signal activate_power_supply(voltage: float, time: int, is_circuit_ready: bool)

enum ConfigType{
	TIME,
	VOLT
}

var _wire_connected_to_positive_output: Wire
var _wire_connected_to_negative_output: Wire
var _is_zoomed_in: bool = false
var _should_increment: bool = false

var _buttons: Array[TextureButton]
var _current_pressed_button: TextureButton
var time: int = 0 # Time in seconds
var volts: int = 50 
var _delta_time: int = 1
var _delta_volts: int = 1

# When the user is typing in a time like 1230, convert to 12:30 and convert time to seconds
var time_string_input: String = "":
	set(value):
		time_string_input = value
		var minutes: int = int(time_string_input) / 100
		var seconds: int = int(time_string_input) % 100
		time = minutes * 60 + seconds
		update_timer_display()

# How much it should increment by if the button is held down long enough
var _time_increment: int = 60
var _volts_increment: int = 50

var _wait_time_threshold: float = .05

func _ready() -> void:
	voltage_line_edit.text = "%d" % [volts]
	for button: TextureButton in find_children("", "TextureButton", true):
		_buttons.append(button)
		button.button_down.connect(_on_screen_button_pressed.bind(button))
		button.button_up.connect(_on_screen_button_released.bind(button))

func _on_start_button_pressed() -> void:
	var circuit_ready: bool = positive_connected and negative_connected
	activate_power_supply.emit(volts, time, circuit_ready) #TODO stuff should happen once wires are connected to the gel rig

func _on_wire_connected(wire: Wire, target_outlet_charge: Wire.Charge) -> void:
	var is_charge_matching: bool = wire.charge == target_outlet_charge
	var is_outlet_positive: bool = target_outlet_charge == Wire.Charge.POSITIVE
	
	if is_charge_matching:
		if is_outlet_positive:
			positive_connected = true
			_wire_connected_to_positive_output = wire
			
		else:
			negative_connected = true
			_wire_connected_to_negative_output = wire
	
	else:
		if is_outlet_positive:
			print("Connecting a Negative to a Positive!")
			_wire_connected_to_positive_output = wire
			
		else:
			print("Connecting a Positive to a Negative!")
			_wire_connected_to_negative_output = wire

## Handle unplugging wires from the Power Supply
func _unplug_handler(body: Node2D) -> void:
	var clicked_on_wire: Wire = body
	
	if _wire_connected_to_positive_output and clicked_on_wire == _wire_connected_to_positive_output: # Pulling out the wire from positive outlet
		positive_connected = false
		_wire_connected_to_positive_output = null
		
		
	elif _wire_connected_to_negative_output and clicked_on_wire == _wire_connected_to_negative_output: # Pulling out the wire from negative outlet
		negative_connected = false
		_wire_connected_to_negative_output = null

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ExitCameraZoom"):
		_on_screen_button_released(_current_pressed_button) # Special case where the user zooms out while still holding down left click
		_is_zoomed_in = false
		for button in _buttons:
			button.disabled = true
			button.mouse_filter = Control.MOUSE_FILTER_IGNORE
		
		time_line_edit.mouse_filter = Control.MOUSE_FILTER_IGNORE
		voltage_line_edit.mouse_filter = Control.MOUSE_FILTER_IGNORE
		
func _on_screen_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event.is_pressed():
		TransitionCamera.target_camera = $ZoomCamera
		_is_zoomed_in = true
		for button in _buttons:
			button.disabled = false
			button.mouse_filter = Control.MOUSE_FILTER_STOP
		
		time_line_edit.mouse_filter = Control.MOUSE_FILTER_STOP
		voltage_line_edit.mouse_filter = Control.MOUSE_FILTER_STOP
		
func _on_screen_mouse_entered() -> void:
	enable_interaction = false

func _on_screen_mouse_exited() -> void:
	if not _is_zoomed_in:
		enable_interaction = true
 
func _on_timer_timeout() -> void:
	var is_pressed: bool = _current_pressed_button.button_pressed
	var button_function: Callable = button_function_dict[_current_pressed_button]["function"]
	var config_type: ConfigType = button_function_dict[_current_pressed_button]["type"]
	
	if is_pressed and config_type == ConfigType.TIME:
		gradually_change(button_function, config_type, _time_increment)

	elif is_pressed and config_type == ConfigType.VOLT:
		gradually_change(button_function, config_type, _volts_increment)
		
func _on_screen_button_pressed(button: TextureButton) -> void:
	_current_pressed_button = button
	button_function_dict[_current_pressed_button]["function"].call() # Call once for single clicks
	$Timer.start()
	
func _on_screen_button_released(_button: TextureButton) -> void:
	$Timer.stop()
	$Timer.wait_time = 0.15
	_delta_time = 1
	_delta_volts = 1
	_should_increment = false
	

func gradually_change(button_func: Callable, type: ConfigType, increment_value: int) -> void:
	# Get either _time or _volts
	var target_var_value: int = button_func.call()
	
	# Decrease the Timer's wait time to gradually increase the speed of changing values
	if (target_var_value % increment_value != 0 or $Timer.wait_time > _wait_time_threshold) and not _should_increment:
		$Timer.wait_time = max($Timer.wait_time - 0.0025, .05)
	
	# Start incrementing the value by a set amount
	else:
		_should_increment = true
		$Timer.wait_time = .3 # Values change more slowly
		$Timer.start() # Timer needs to start again to update the wait_time
		change_delta_rate(type, increment_value)
		
## Updates the delta for time or volts to a set increment
func change_delta_rate(type: ConfigType, new_delta: int) -> void:
	if type == ConfigType.TIME:
		_delta_time = new_delta 
		
	elif type == ConfigType.VOLT:
		_delta_volts = new_delta

func increment_time() -> int:
	time += _delta_time
	update_timer_display()
	return time
	
func decrement_time() -> int:
	if time > 0:
		time -= _delta_time
		update_timer_display()
	
	return time
		
func update_timer_display() -> void:
	var minutes: int = time / 60
	var seconds: int = time % 60
	$Screen/TimeContainer/HBoxContainer/Time.text = "%02d:%02d" % [minutes, seconds]

func increment_volts() -> int:
	volts += _delta_volts
	volts = min(volts, 999)
	_update_volt_display()
	
	return volts
	
func decrement_volts() -> int:
	if volts > 0:
		volts -= _delta_volts
		_update_volt_display()
	
	return volts
	
func _update_volt_display() -> void:
	voltage_line_edit.text = "%d" % [volts]
