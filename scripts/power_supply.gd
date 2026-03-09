extends LabBody
class_name PowerSupply


enum TimerState
{
	OFF,
	INPUTTING,
	ON,
}


const MAX_INPUT_TIME := 60 * 99 + 59


@export var min_voltage: float = 0
@export var max_voltage: float = 999
@export_custom(PROPERTY_HINT_NONE, "suffix:V/rad") var voltage_per_radian: float = 60 / PI


var _input_voltage: float = min_voltage
var _output_voltage: float = 0.0
var _is_outputting: bool = false
# Amount added to the displayed output voltage to make it look like it's fluctuating a bit.
var _volt_fluctuation: float = 0
var _timer_state := TimerState.OFF
var _input_time: int = 0


func _ready() -> void:
	super()
	_update_display()
	_update_timer_state(_timer_state)

func _physics_process(delta: float) -> void:
	super(delta)

	var target: CircuitComponent = $CircuitComponent.get_connected_component()
	if target:
		if target.closed and _is_outputting:
			target.voltage = float(_input_voltage) * $CircuitComponent.get_connected_component_direction()
		else:
			target.voltage = 0.0

		_output_voltage = abs(target.voltage)
	else:
		_output_voltage = 0.0

	_update_display()

func is_hovered() -> bool:
	# Don't allow the power supply to be picked up while zoomed in, so the buttons can be pressed.
	return super() and not Game.main.get_camera_focus_owner()

func _update_display() -> void:
	if _timer_state != TimerState.OFF:
		var time_to_show: float = $LabTimer.time_left if _timer_state == TimerState.ON else _input_time
		var t: int = ceili(max(time_to_show, 0))
		var minutes: int = t / 60
		var seconds: int = t % 60
		%TimeDisplay.string = str(minutes * 100 + seconds)

	var disp_voltage := _output_voltage + _volt_fluctuation if _is_outputting else _input_voltage
	disp_voltage = clamp(disp_voltage, min_voltage, max_voltage)
	%VoltDisplay.string = str(roundi(disp_voltage))

	%OutputLightOff.visible = not _is_outputting
	%OutputLightOn.visible = _is_outputting

# Update the appearance of the timer thing based on the state.
func _update_timer_state(state: TimerState) -> void:
	_timer_state = state
	if state == TimerState.INPUTTING:
		%ColonBlinkAnimationPlayer.play("time_colon_blink")
	else:
		%ColonBlinkAnimationPlayer.stop()
	%TimeDisplay/Colon.visible = _timer_state != TimerState.OFF
	if state == TimerState.OFF:
		%TimeDisplay.string = "0FF"

func _update_timer_pause() -> void:
	$LabTimer.paused = not _is_outputting or _timer_state != TimerState.ON


func _on_circuit_component_disconnected(component: CircuitComponent) -> void:
	component.voltage = 0.0

func _on_dial_rotated(angle: float) -> void:
	_input_voltage += angle * voltage_per_radian
	_input_voltage = clamp(_input_voltage, min_voltage, max_voltage)
	_update_display()

func _on_power_button_pressed() -> void:
	_is_outputting = not _is_outputting
	_update_display()
	_update_timer_pause()

func _on_volt_fluctuation_timer_timeout() -> void:
	_volt_fluctuation = randf_range(-1.1, 1.1)

func _on_time_toggle_button_pressed() -> void:
	match _timer_state:
		TimerState.OFF:
			_input_time = 0
			_update_timer_state(TimerState.INPUTTING)
		TimerState.INPUTTING:
			$LabTimer.start(_input_time)
			_update_timer_state(TimerState.ON)
		TimerState.ON:
			$LabTimer.stop()
			_update_timer_state(TimerState.OFF)
	_update_timer_pause()

func _on_time_up_button_started_holding() -> void:
	_input_time = clamp(_input_time + 1, 0, MAX_INPUT_TIME)

func _on_time_up_button_stopped_holding() -> void:
	pass # Replace with function body.

func _on_time_down_button_started_holding() -> void:
	_input_time = clamp(_input_time - 1, 0, MAX_INPUT_TIME)

func _on_time_down_button_stopped_holding() -> void:
	pass # Replace with function body.

func _on_lab_timer_timeout() -> void:
	_is_outputting = false
	_update_display()
	_update_timer_state(TimerState.OFF)
	_update_timer_pause()
