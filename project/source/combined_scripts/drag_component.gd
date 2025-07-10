## Allows a `RigidBody2D` to be dragged and dropped with the mouse.
class_name DragComponent
extends Node2D


## The body to be dragged.
@export var body: RigidBody2D

## When the mouse is over this sprite, it will be highlighted, and pressing the
## left mouse button while hovering it will allow it to be dragged.
@export var interact_sprite: Sprite2D


var _offset: Vector2 = Vector2.ZERO
var _is_dragging: bool = false
var _shader_mat: ShaderMaterial = ShaderMaterial.new()


func _ready() -> void:
	_shader_mat.shader = preload("res://shaders/outline.gdshader")
	
	var top_material := interact_sprite.material
	while top_material:
		top_material = top_material.next_pass

	if top_material: top_material.next_pass = _shader_mat
	else: interact_sprite.material = _shader_mat


func _physics_process(delta: float) -> void:
	if _is_dragging:
		body.global_position = get_global_mouse_position() + _offset

		if abs(body.global_rotation) > 0.001:
			var is_rotating_clockwise := body.global_rotation < 0
			body.global_rotation -= body.global_rotation * delta * 50

			if is_rotating_clockwise: body.global_rotation = min(0.0, body.global_rotation)
			else: body.global_rotation = max(0.0, body.global_rotation)

func _process(_delta: float) -> void:
	_shader_mat.set(&"shader_parameter/enabled", _is_hovering_sprite() and not _is_dragging)

func _unhandled_input(e: InputEvent) -> void:
	if e.is_action_pressed(&"DragLabObject") and _is_hovering_sprite():
		_is_dragging = true
		body.set_deferred(&"freeze", true)
		_offset = body.global_position - get_global_mouse_position()
	elif e.is_action_released(&"DragLabObject") and _is_dragging:
		_is_dragging = false
		body.set_deferred(&"freeze", false)

func _is_hovering_sprite() -> bool:
	return interact_sprite.is_pixel_opaque(interact_sprite.to_local(get_global_mouse_position()))
