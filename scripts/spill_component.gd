class_name SpillComponent
extends Node2D
## Allows fluid to be spilled from a container.
##
## If any substance in [member substance_display_polygon] is touching this node, then it will be
## spilled into [member target_container].


## Substance polygon displaying the container to be spilled. If a substance is displayed at the
## location of this node, then it will be spilled.
@export var substance_display_polygon: SubstanceDisplayPolygon
## The container to add the spilled substance to.
@export var target_container: ContainerComponent
## Rate of spillage in mL per second (in real time rather than lab time).
@export_custom(PROPERTY_HINT_NONE, "suffix:mL/s") var spill_rate: float = 1


func _physics_process(delta: float) -> void:
	if not substance_display_polygon or not target_container: return

	var s := substance_display_polygon.get_substance_at_global(global_position)
	if s: target_container.add(s.take_volume(spill_rate * delta))
