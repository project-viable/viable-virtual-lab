class_name SpillComponent
extends Node2D
## Allows fluid to be spilled from a container.
##
## If any substance in [member substance_display_polygon] is touching this node, then it will be
## spilled into [member target_container]. The spill rate depends on the viscosity of the substance
## and the angle of the container.


# Spill rate of fluids with zero viscosity in mL/s.
const DEFAULT_SPILL_RATE: float = 40



## Substance polygon displaying the container to be spilled. If a substance is displayed at the
## location of this node, then it will be spilled.
@export var substance_display_polygon: SubstanceDisplayPolygon
## The container to add the spilled substance to.
@export var target_container: ContainerComponent

# Minimum absolute value of this container's global angle to pour.
@export_custom(PROPERTY_HINT_NONE, "suffix:rad") var min_pour_angle: float = PI / 4
# Maximum absolute value of this container's global angle to pour. At this angle or above, the pour
# rate will be at its maximum.
@export_custom(PROPERTY_HINT_NONE, "suffix:rad") var max_pour_angle: float = 3 * PI / 4


func _physics_process(delta: float) -> void:
	if not substance_display_polygon or not target_container: return

	var s := substance_display_polygon.get_substance_at_global(global_position)
	if s:
		var angle_factor: float = ease(inverse_lerp(min_pour_angle, max_pour_angle, abs(global_rotation)), 5)
		var pour_factor: float =  angle_factor * (1.0 - ease(s.get_viscosity(), 0.4))
		target_container.add(s.take_volume(DEFAULT_SPILL_RATE * pour_factor * delta))
