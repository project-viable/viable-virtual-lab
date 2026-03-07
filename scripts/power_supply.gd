extends LabBody
class_name PowerSupply


@export var min_voltage: float = 0
@export var max_voltage: float = 999
@export_custom(PROPERTY_HINT_NONE, "suffix:V/rad") var voltage_per_radian: float = 60 / PI


var _input_voltage: float = min_voltage
var _output_voltage: float = 0.0
var _is_outputting: bool = false


func _ready() -> void:
	super()
	_update_display()

func _physics_process(delta: float) -> void:
	super(delta)

	var target: CircuitComponent = $CircuitComponent.get_connected_component()
	if target:
		if target.closed and $LabTimer.time_left > 0 and _is_outputting:
			target.voltage = float(_input_voltage) * $CircuitComponent.get_connected_component_direction()
		else:
			target.voltage = 0.0

		_output_voltage = target.voltage
	else:
		_output_voltage = 0.0

	_update_display()

func is_hovered() -> bool:
	# Don't allow the power supply to be picked up while zoomed in, so the buttons can be pressed.
	return super() and not Game.main.get_camera_focus_owner()

func _update_display() -> void:
	var t: int = ceili(max($LabTimer.time_left, 0))
	var minutes: int = t / 60
	var seconds: int = t % 60
	%TimeDisplay.string = str(minutes * 100 + seconds)

	var disp_voltage := _output_voltage if _is_outputting else _input_voltage
	%VoltDisplay.string = str(roundi(disp_voltage))

	%OutputLightOff.visible = not _is_outputting
	%OutputLightOn.visible = _is_outputting

func _on_circuit_component_disconnected(component: CircuitComponent) -> void:
	component.voltage = 0.0

func _on_dial_rotated(angle: float) -> void:
	_input_voltage += angle * voltage_per_radian
	_input_voltage = clamp(_input_voltage, min_voltage, max_voltage)
	_update_display()

func _on_power_button_pressed() -> void:
	_is_outputting = not _is_outputting
	# Only count down time while outputting.
	$LabTimer.paused = not _is_outputting
	_update_display()
