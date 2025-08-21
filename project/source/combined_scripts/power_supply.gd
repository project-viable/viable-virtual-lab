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
var _time: int = 0 # Time in seconds
var _volts: int = 50 
var _delta_time: int = 1
var _delta_volts: int = 1
var time_string_input: String = ""

# How much it should increment by if the button is held down long enough
var _time_increment: int = 60
var _volts_increment: int = 50

var _wait_time_threshold: float = .05

func _ready() -> void:
	voltage_line_edit.text = "%d" % [_volts]
	for button: TextureButton in find_children("", "TextureButton", true):
		_buttons.append(button)
		button.button_down.connect(_on_screen_button_pressed.bind(button))
		button.button_up.connect(_on_screen_button_released.bind(button))

func _on_start_button_pressed() -> void:
	var circuit_ready: bool = positive_connected and negative_connected
	activate_power_supply.emit(_volts, _time, circuit_ready) #TODO stuff should happen once wires are connected to the gel rig

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
		_is_zoomed_in = false
		for button in _buttons:
			button.mouse_filter = Control.MOUSE_FILTER_IGNORE
		
		time_line_edit.mouse_filter = Control.MOUSE_FILTER_IGNORE
		voltage_line_edit.mouse_filter = Control.MOUSE_FILTER_IGNORE
		
	if event.is_action_pressed("ui_text_backspace") and time_line_edit.has_focus():
		time_string_input = time_string_input.left(-1)
		update_timer_display()
		
func _on_screen_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event.is_pressed():
		TransitionCamera.target_camera = $ZoomCamera
		_is_zoomed_in = true
		for button in _buttons:
			button.mouse_filter = Control.MOUSE_FILTER_STOP
		
		time_line_edit.mouse_filter = Control.MOUSE_FILTER_STOP
		voltage_line_edit.mouse_filter = Control.MOUSE_FILTER_STOP
		
func _on_screen_mouse_entered() -> void:
	$DragComponent.enable_interaction = false

func _on_screen_mouse_exited() -> void:
	if not _is_zoomed_in:
		$DragComponent.enable_interaction = true
 
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
	
		

func _on_screen_button_released(button: TextureButton) -> void:
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
	_time += _delta_time
	update_timer_display()
	return _time
	
func decrement_time() -> int:
	if _time > 0:
		_time -= _delta_time
		update_timer_display()
	
	return _time
		
func update_timer_display() -> void:
	var minutes: int
	var seconds: int
	
	# If a user is typing in a number like 1230, convert it to 12:30 and update _time in seconds
	if time_line_edit.has_focus():
		var temp_time: int = int(time_string_input)
		minutes = temp_time / 100
		seconds = temp_time % 100
		_time = minutes * 60 + seconds
		
	else: # Button inputs
		minutes = _time / 60
		seconds = _time % 60
	
	$Screen/TimeContainer/HBoxContainer/Time.text = "%02d:%02d" % [minutes, seconds]

func increment_volts() -> int:
	_volts += _delta_volts
	_volts = min(_volts, 999)
	_update_volt_display()
	
	return _volts
	
func decrement_volts() -> int:
	if _volts > 0:
		_volts -= _delta_volts
		_update_volt_display()
	
	return _volts
	
func _update_volt_display() -> void:
	voltage_line_edit.text = "%d" % [_volts]

## Basically just using this to get number input
func _on_time_line_edit_text_changed(new_text: String) -> void:
	var line_edit: LineEdit = time_line_edit
	if time_string_input.length() < 4 and new_text.is_valid_int():
		time_string_input += new_text
	
	line_edit.text = ""
	update_timer_display()


func _on_line_edit_focus_exited() -> void:
	# Since time is in seconds, the string should be what's shown exactly on the screen
	# In this case the minutes and seconds concatenated to one another
	time_string_input = str(_time / 60) + str(_time % 60)


func _on_voltage_line_edit_text_changed(new_text: String) -> void:
	var column: int = voltage_line_edit.caret_column
	var filtered_text: String = ""
	
	var regex: RegEx = RegEx.new()
	regex.compile("\\d+")
	
	var numbers: Array[RegExMatch] = regex.search_all(new_text)
	
	for number in numbers:
		filtered_text += str(number.get_string())
	
	voltage_line_edit.text = filtered_text
	voltage_line_edit.caret_column = column
	_volts = int(voltage_line_edit.text)

func _on_voltage_line_edit_focus_exited() -> void:
	if voltage_line_edit.text.is_empty():
		_update_volt_display()
