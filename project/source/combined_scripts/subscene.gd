class_name Subscene
extends ReferenceRect
## Parent of a set of nodes that can be displayed and interacted with as a popup.


var default_location: Vector2 = global_position


func _ready() -> void:
	top_level = true
	Subscenes.allocate_subscene(self)


## Move this [Subscene] back to its default location (which will not overlap with any other
## subscene).
func reset_to_default_location() -> void:
	global_position = default_location
