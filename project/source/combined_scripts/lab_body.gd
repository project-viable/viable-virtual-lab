## An object that can be dragged around.
class_name LabBody
extends RigidBody2D


func _ready() -> void: stop_dragging()

func start_dragging() -> void:
	set_deferred(&"collision_mask", 0)
	set_deferred(&"freeze", true)

func stop_dragging() -> void:
	set_deferred(&"collision_mask", 1)
	set_deferred(&"freeze", false)
