@tool
extends Sprite2D
class_name DimensionSprite

@export var OverrideDimensions: bool: set = SetOverride
@export var SpriteDimensions: Vector2: set = SetDimensions

# Called when the node enters the scene tree for the first time.
func SetOverride(new_val: bool) -> void:
	OverrideDimensions = new_val
	
	SetDimensions(SpriteDimensions)
	
	#we just turned it off, and we're in the editor, and the dimensions were (0, 0) before, the user probably doesn't actually want the thing to be (0, 0)
	if (not OverrideDimensions) and (Engine.is_editor_hint()) and (SpriteDimensions == Vector2(0, 0)):
		#so just set it to the default scale
		scale = Vector2(1, 1)

func SetDimensions(new_dimensions: Vector2) -> void:
	SpriteDimensions = new_dimensions
	
	if OverrideDimensions:
		scale = Vector2(SpriteDimensions.x / texture.get_width(), SpriteDimensions.y / texture.get_height())
