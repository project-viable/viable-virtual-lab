extends LabBody
class_name PowerSupply


@export var min_voltage: float = 0
@export var max_voltage: float = 999
@export_custom(PROPERTY_HINT_NONE, "suffix:V/rad") var voltage_per_radian: float = 60 / PI


var _input_voltage: float = min_voltage


func _ready() -> void:
	super()
	_update_display()

func _physics_process(delta: float) -> void:
	super(delta)

	var target: CircuitComponent = $CircuitComponent.get_connected_component()
	if not target: return

	if target.closed and $LabTimer.time_left > 0:
		target.voltage = float(_input_voltage) * $CircuitComponent.get_connected_component_direction()
	else:
		target.voltage = 0.0

func is_hovered() -> bool:
	# Don't allow the power supply to be picked up while zoomed in, so the buttons can be pressed.
	return super() and not Game.main.get_camera_focus_owner()

func _update_display() -> void:
	var t: int = ceili(max($LabTimer.time_left, 0))
	var minutes: int = t / 60
	var seconds: int = t % 60
	%TimeDisplay.string = str(minutes * 100 + seconds)
	%VoltDisplay.string = str(roundi(_input_voltage))

func _on_circuit_component_disconnected(component: CircuitComponent) -> void:
	component.voltage = 0.0

func _on_dial_rotated(angle: float) -> void:
	_input_voltage += angle * voltage_per_radian
	_input_voltage = clamp(_input_voltage, min_voltage, max_voltage)
	_update_display()
