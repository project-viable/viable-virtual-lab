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

## If set to [code]true[/code], then substances will be spilled even without a target container to
## spill into.
@export var spill_without_target_container: bool = false

# Minimum absolute value of this container's global angle to pour.
@export_custom(PROPERTY_HINT_NONE, "suffix:rad") var min_pour_angle: float = PI / 4
# Maximum absolute value of this container's global angle to pour. At this angle or above, the pour
# rate will be at its maximum.
@export_custom(PROPERTY_HINT_NONE, "suffix:rad") var max_pour_angle: float = 3 * PI / 4
## Rate that liquid will constantly drain from this.
@export_custom(PROPERTY_HINT_NONE, "suffix:mL/s") var constant_spill_rate: float = 0.0


func _physics_process(delta: float) -> void:
	if not substance_display_polygon or (not target_container and not spill_without_target_container):
		return

	var s := substance_display_polygon.get_substance_at_global(global_position)
	if s:
		var angle_factor: float = ease(inverse_lerp(min_pour_angle, max_pour_angle, abs(global_rotation)), 5)
		var pour_factor: float =  angle_factor * (1.0 - ease(s.get_viscosity(), 0.4))
		var pour_amount: float = (DEFAULT_SPILL_RATE * pour_factor + constant_spill_rate) * delta
		var spilled := s.take_volume(pour_amount)
		if target_container:
			target_container.add(spilled)
