## Allows a `RigidBody2D` to be dragged and dropped with the mouse.
class_name DragComponent
extends Node2D


## The body to be dragged.
@export var body: RigidBody2D

## This will be outlined when the mouse is hovering it, and clicking while
## hovering will allow dragging.
@export var interact_canvas_group: SelectableCanvasGroup


var _offset: Vector2 = Vector2.ZERO
var _is_dragging: bool = false
var _velocity: Vector2 = Vector2.ZERO


func _ready() -> void:
	# We put these in a group just to make it faster for `Selectables` to find all drag
	# components.
	add_to_group(&"drag_component")

func _physics_process(delta: float) -> void:
	if _is_dragging:
		if abs(body.global_rotation) > 0.001:
			var is_rotating_clockwise := body.global_rotation < 0
			body.global_rotation -= body.global_rotation * delta * 50

			if is_rotating_clockwise: body.global_rotation = min(0.0, body.global_rotation)
			else: body.global_rotation = max(0.0, body.global_rotation)

		var dest_pos := body.to_global(body.get_local_mouse_position() - _offset)
		_velocity = (dest_pos - body.global_position) / delta
		body.global_position = dest_pos

func _process(_delta: float) -> void:
	interact_canvas_group.is_outlined = _is_hovering() and not _is_dragging

func _unhandled_input(e: InputEvent) -> void:
	if e.is_action_pressed(&"DragLabObject") and _is_hovering():
		_is_dragging = true
		body.set_deferred(&"freeze", true)

		# Move the body to the front by moving it to the end of its parent's children.
		var body_parent: Node = body.get_parent()
		if body_parent:
			body_parent.call_deferred(&"remove_child", body)
			body_parent.call_deferred(&"add_child", body)

		_offset = body.get_local_mouse_position()
	elif e.is_action_released(&"DragLabObject") and _is_dragging:
		_is_dragging = false
		body.set_deferred(&"freeze", false)

		# Fling the body after dragging depending on how it was moving when being dragged.
		var global_offset := body.to_global(_offset) - body.global_position
		body.call_deferred(&"apply_impulse", _velocity / 10.0, global_offset)

func _is_hovering() -> bool: return Selectables.hovered_drag_component == self
