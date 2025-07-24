## An object that can be dragged around.
class_name LabBody
extends RigidBody2D


enum Mode
{
	NORMAL, # Affected by physics. Only collides with things in the `SURFACE` layer.
	DRAGGING, # No collision nor physics; can be safely dragged around.
	SURFACE, # Other objects can collide with this. Useful for objects like the scale that can have other objects sit on them.
}


@export var default_mode: Mode = Mode.NORMAL


func _ready() -> void: set_mode(default_mode)

func start_dragging() -> void: set_mode(Mode.DRAGGING)
func stop_dragging() -> void: set_mode(default_mode)

func set_mode(mode: Mode) -> void:
	var layer: int = 1 if mode == Mode.SURFACE else 0
	var mask: int = 0 if mode == Mode.DRAGGING else 1
	var freeze: bool = mode == Mode.DRAGGING

	set_deferred(&"collision_layer", layer)
	set_deferred(&"collision_mask", mask)
	set_deferred(&"freeze", freeze)
