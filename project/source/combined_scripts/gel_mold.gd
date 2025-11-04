class_name GelMold
extends LabBody


## Voltage, where positive is down the gel.
@export var voltage: float = 0.0


func _physics_process(delta: float) -> void:
	for i in 5:
		for s in get_well(i + 1).substances:
			if s is DNASolutionSubstance:
				s.run_voltage(voltage, delta * LabTime.time_scale, 1.0)

## Wells are numbered 1 to 5.
func get_well(i: int) -> ContainerComponent:
	return get_node_or_null("Subscene/Well%s" % [i])
