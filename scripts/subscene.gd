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

	# We want to see the subscene when editing the scene directly containing it , but we don't want
	# it floating around and getting in the way when editing any scene containing that object, so we
	# hide it if we're not editing the direct scene owning this.
	if Engine.is_editor_hint() and owner != null and get_tree().edited_scene_root != owner:
		hide()
	else:
		# If an object with a subscene is set to have editable children, then the modified
		# visibility of this subscene will be stored, since it's different from the default, which
		# will cause it to always be invisible. So we just do this to make sure this subscene is
		# always visible when actually running the simulation.
		show()

func reset_position() -> void: global_position = default_position
