@tool
class_name Subscene
extends ReferenceRect
## Rectangular region that will automatically be moved to a free space in the world not overlapping
## any other subscene. Subscenes can be used to make a secondary, zoomed-in view of an object, and
## can be displayed using a [SubsceneCamera].


## Free space dedicated to this object. This is set when allocating this subscene via
## [method Subscenes.allocate]
var default_position: Vector2 = Vector2.ZERO


func _enter_tree() -> void:
	top_level = true
	if not Engine.is_editor_hint():
		Subscenes.allocate(self)
	if Engine.is_editor_hint() and owner != null and get_tree().edited_scene_root != owner:
		hide()

func reset_position() -> void: global_position = default_position
