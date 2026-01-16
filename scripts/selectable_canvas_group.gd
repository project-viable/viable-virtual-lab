## A `CanvasGroup` that can be outlined and can check whether any child sprites are hovered.
class_name SelectableCanvasGroup
extends CanvasGroup


@export var outline_thickness: float = 5
@export var outline_color: Color = Color.YELLOW
@export var is_outlined: bool = false


var draw_order_this_frame: int = 0


var _shader_mat: ShaderMaterial = ShaderMaterial.new()


func _ready() -> void:
	_shader_mat.shader = preload("res://shaders/outline.gdshader")
	material = _shader_mat

func _process(_delta: float) -> void:
	fit_margin = outline_thickness + 5
	_shader_mat.set(&"shader_parameter/enabled", is_outlined)
	_shader_mat.set(&"shader_parameter/radius", outline_thickness)
	_shader_mat.set(&"shader_parameter/outline_color", outline_color)

## Hacky way to determine which one is drawn on top.
func _draw() -> void:
	draw_order_this_frame = Interaction.get_next_draw_order()

## True if the mouse is hovering any `Sprite2D`s that are children of this node.
func is_mouse_hovering() -> bool:
	for s: Sprite2D in find_children("", "Sprite2D"):
		if s.is_visible_in_tree() and s.is_pixel_opaque(s.to_local(Cursor.virtual_mouse_position)):
			return true
	return false
