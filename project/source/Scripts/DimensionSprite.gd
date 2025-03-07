@tool
extends Sprite2D
class_name DimensionSprite

@export var override_dimensions: bool: set = set_override
@export var sprite_dimensions: Vector2: set = set_dimensions

# Called when the node enters the scene tree for the first time.
func set_override(new_val: bool) -> void:
	override_dimensions = new_val
	
	set_dimensions(sprite_dimensions)
	
	#we just turned it off, and we're in the editor, and the dimensions were (0, 0) before, the user probably doesn't actually want the thing to be (0, 0)
	if (not override_dimensions) and (Engine.is_editor_hint()) and (sprite_dimensions == Vector2(0, 0)):
		#so just set it to the default scale
		scale = Vector2(1, 1)

func set_dimensions(new_dimensions: Vector2) -> void:
	sprite_dimensions = new_dimensions
	
	if override_dimensions:
		scale = Vector2(sprite_dimensions.x / texture.get_width(), sprite_dimensions.y / texture.get_height())
