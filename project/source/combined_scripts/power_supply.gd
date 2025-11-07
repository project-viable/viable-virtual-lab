extends LabBody
class_name PowerSupply

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

enum ConfigType{
	TIME,
	VOLT
}

enum CurrentDirection{
	FORWARD,
	REVERSE
}

var _should_increment: bool = false
var _is_power_supply_connected: bool = false
var _object_to_recieve_current: WireConnectableComponent
var positive_terminal_wire: Wire
var negative_terminal_wire: Wire

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
	super()
	voltage_line_edit.text = "%d" % [volts]
	for button: TextureButton in find_children("", "TextureButton", true):
		_buttons.append(button)
		button.button_down.connect(_on_screen_button_pressed.bind(button))
		button.button_up.connect(_on_screen_button_released.bind(button))

func _physics_process(delta: float) -> void:
	super(delta)
	# If the timer is still running, we are running current.
	var prev_current_recipient := _object_to_recieve_current
	# This changes state for some reason.
	# TODO: Fix this hacky way of doing this.
	if not _is_circuit_ready(): _object_to_recieve_current = null

	if prev_current_recipient and prev_current_recipient != _object_to_recieve_current:
		prev_current_recipient.voltage = 0

	# If there is time left, we are still running.
	var cur_voltage: float = float(volts) if $LabTimer.time_left > 0 else 0.0
	if _object_to_recieve_current:
		_object_to_recieve_current.voltage = cur_voltage
		var dir := get_current_direction()
		if dir == CurrentDirection.REVERSE: _object_to_recieve_current.voltage *= -1

	if $LabTimer.time_left > 0:
		time = round($LabTimer.time_left)
		update_timer_display()

func is_hovered() -> bool:
	# Don't allow the power supply to be picked up while zoomed in, so the buttons can be pressed.
	return super() and not Game.main.get_camera_focus_owner()

func _on_start_button_pressed() -> void:
	$LabTimer.start(time)
 
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

## Can be triggered from [signal WireConnectableComponent.terminals_connected] signal whenever a wire is 
## connected to a terminal.
func _on_wire_connection(is_every_terminal_connected: bool) -> void:
	_is_power_supply_connected = is_every_terminal_connected

## Checks if both terminals of the power supply are connected
## and if the other ends of those wires are both connected to 
## another object.
func _is_circuit_ready() -> bool:
	# Both terminals of the power supply must be connected
	if not _is_power_supply_connected:
		return false
	
	positive_terminal_wire = $WireConnectableComponent.get_positive_terminal_wire()
	negative_terminal_wire = $WireConnectableComponent.get_negative_terminal_wire()
	
	var positive_wire_other_end_component: WireConnectableComponent = positive_terminal_wire.get_component_on_other_end()
	var negative_wire_other_end_component: WireConnectableComponent = negative_terminal_wire.get_component_on_other_end()
	
	# Both of the wires connected to the power supply must have their other ends
	# be connected to the same target
	if positive_wire_other_end_component == null \
			or positive_wire_other_end_component != negative_wire_other_end_component:
		return false

	else:
		_object_to_recieve_current = positive_wire_other_end_component
		return true

## Determines the direction of current based on wire connections.
## Returns FORWARD if each wire connects matching terminals (positive to positive, negative to negative),
## otherwise returns REVERSE.
func get_current_direction() -> CurrentDirection:
	var target: WireConnectableComponent = _object_to_recieve_current
	var target_positive_terminal_wire: Wire = target.get_positive_terminal_wire()
	var target_negative_terminal_wire: Wire = target.get_negative_terminal_wire()
	
	# Both ends of a wire are connected to a positive terminal, resulting in a forward current direction
	if target_positive_terminal_wire.other_end == positive_terminal_wire \
		and target_negative_terminal_wire.other_end == negative_terminal_wire:
			return CurrentDirection.FORWARD
	
	# Ends of a wire are connected to different terminal denotations, resulting in a reversed current direction
	else:
		return CurrentDirection.REVERSE

func _on_zoom_selectable_area_zoomed_in() -> void:
	for button in _buttons:
		button.disabled = false
		button.mouse_filter = Control.MOUSE_FILTER_STOP
	
	time_line_edit.mouse_filter = Control.MOUSE_FILTER_STOP
	voltage_line_edit.mouse_filter = Control.MOUSE_FILTER_STOP

func _on_zoom_selectable_area_zoomed_out() -> void:
	_on_screen_button_released(_current_pressed_button) # Special case where the user zooms out while still holding down left click
	for button in _buttons:
		button.disabled = true
		button.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	time_line_edit.mouse_filter = Control.MOUSE_FILTER_IGNORE
	voltage_line_edit.mouse_filter = Control.MOUSE_FILTER_IGNORE
