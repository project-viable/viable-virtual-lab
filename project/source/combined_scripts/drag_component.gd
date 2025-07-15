## Allows a `RigidBody2D` to be dragged and dropped with the mouse.
class_name DragComponent
extends SelectableComponent


## The body to be dragged.
@export var body: RigidBody2D

var _offset: Vector2 = Vector2.ZERO
var _velocity: Vector2 = Vector2.ZERO


func _physics_process(delta: float) -> void:
	if is_held:
		if abs(body.global_rotation) > 0.001:
			var is_rotating_clockwise := body.global_rotation < 0
			body.global_rotation -= body.global_rotation * delta * 50

			if is_rotating_clockwise: body.global_rotation = min(0.0, body.global_rotation)
			else: body.global_rotation = max(0.0, body.global_rotation)

		var dest_pos := body.to_global(body.get_local_mouse_position() - _offset)
		_velocity = (dest_pos - body.global_position) / delta
		body.global_position = dest_pos

func start_holding() -> void:
		body.set_deferred(&"freeze", true)

		# Move the body to the front by moving it to the end of its parent's children.
		var body_parent: Node = body.get_parent()
		if body_parent:
			body_parent.call_deferred(&"remove_child", body)
			body_parent.call_deferred(&"add_child", body)

		_offset = body.get_local_mouse_position()

func stop_holding() -> void:
		body.set_deferred(&"freeze", false)

		# Fling the body after dragging depending on how it was moving when being dragged.
		var global_offset := body.to_global(_offset) - body.global_position
		body.call_deferred(&"apply_impulse", _velocity / 10.0, global_offset)
