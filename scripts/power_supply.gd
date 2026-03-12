extends Node2D
class_name PowerSupply


enum TimerState
{
	OFF,
	INPUTTING,
	ON,
}


const MAX_INPUT_TIME := 60 * 99 + 59


@export_custom(PROPERTY_HINT_NONE, "suffix:V") var min_voltage: float = 0
@export_custom(PROPERTY_HINT_NONE, "suffix:V") var max_voltage: float = 999
## Standard deviation of random fluctuations in the displayed current. This doesn't affect the
## actual current supplied, but it does make it look a bit more realistic. The fluctuations are
## normally distributed because that sounds right to me somehow.
@export_custom(PROPERTY_HINT_NONE, "suffix:A") var amp_fluctuation_std: float = 0.001
@export_custom(PROPERTY_HINT_NONE, "suffix:V/rad") var voltage_per_radian: float = 60 / PI


var _input_voltage: float = min_voltage
var _output_current: float = 0.0
var _is_outputting: bool = false
# Amount added to the displayed output voltage to make it look like it's fluctuating a bit.
var _amp_fluctuation: float = 0
var _timer_state := TimerState.OFF
var _input_time_mins: int = 0
# We want integer voltages, but if we just round the value when the dial moves, then tiny movements
# of the dial will not add enough to affect the voltage, which is very confusing when trying to
# carefully adjust the voltage. To fix this, we keep track of the extra accumulated value here.
var _dial_voltage_accumulated: float = 0


func _ready() -> void:
	_update_display()
	_update_timer_state(_timer_state)

func _physics_process(_delta: float) -> void:
	var target: CircuitComponent = $CircuitComponent.get_connected_component()
	if target:
		if target.closed and _is_outputting:
			target.voltage = float(_input_voltage) * $CircuitComponent.get_connected_component_direction()
		else:
			target.voltage = 0.0

		_output_current = abs(target.voltage / target.resistance)
	else:
		_output_current = 0.0

	_update_display()

func _update_display() -> void:
	if _timer_state != TimerState.OFF:
		# Divide by 60 to get minutes.
		var time_to_show: float = $LabTimer.time_left / 60.0 if _timer_state == TimerState.ON else _input_time_mins
		var t: int = ceili(max(time_to_show, 0))
		var hours: int = t / 60
		var minutes: int = t % 60
		%TimeDisplay.string = str(hours * 100 + minutes)

	var disp_current := _output_current if _is_outputting else 0.0
	# Don't fluctuate the current if the output is basically zero.
	if _is_outputting and _output_current >= amp_fluctuation_std * 2:
		disp_current += _amp_fluctuation
	disp_current = clamp(disp_current, min_voltage, max_voltage)

	%AmpDisplay.string = ("%1.3f" % disp_current).remove_chars(".")
	%VoltDisplay.string = ("%1.2f" % _input_voltage).remove_chars(".")

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
	_dial_voltage_accumulated += angle * voltage_per_radian
	var dial_input_voltage: float = _input_voltage + _dial_voltage_accumulated
	dial_input_voltage = clamp(dial_input_voltage, min_voltage, max_voltage)
	_input_voltage = floor(dial_input_voltage)
	_dial_voltage_accumulated = dial_input_voltage - _input_voltage
	_update_display()

func _on_power_button_pressed() -> void:
	_is_outputting = not _is_outputting
	_update_display()
	_update_timer_pause()

func _on_amp_fluctuation_timer_timeout() -> void:
	_amp_fluctuation = randfn(0, amp_fluctuation_std)

func _on_time_toggle_button_pressed() -> void:
	match _timer_state:
		TimerState.OFF:
			_input_time_mins = 0
			_update_timer_state(TimerState.INPUTTING)
		TimerState.INPUTTING:
			$LabTimer.start(_input_time_mins * 60.0)
			_update_timer_state(TimerState.ON)
		TimerState.ON:
			$LabTimer.stop()
			$LabTimer.wait_time = 0.0
			_update_timer_state(TimerState.OFF)
	_update_timer_pause()

func _on_time_up_button_started_holding() -> void:
	_input_time_mins = clamp(_input_time_mins + 1, 0, MAX_INPUT_TIME)

func _on_time_up_button_stopped_holding() -> void:
	pass # Replace with function body.

func _on_time_down_button_started_holding() -> void:
	_input_time_mins = clamp(_input_time_mins - 1, 0, MAX_INPUT_TIME)

func _on_time_down_button_stopped_holding() -> void:
	pass # Replace with function body.

func _on_lab_timer_timeout() -> void:
	_is_outputting = false
	_update_display()
	_update_timer_state(TimerState.OFF)
	_update_timer_pause()
