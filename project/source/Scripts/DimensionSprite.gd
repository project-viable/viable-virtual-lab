tool
extends Sprite
class_name DimensionSprite

export var OverrideDimensions: bool setget SetOverride
export var SpriteDimensions: Vector2 setget SetDimensions

# Called when the node enters the scene tree for the first time.
func SetOverride(newVal):
	OverrideDimensions = newVal
	
	SetDimensions(SpriteDimensions)
	
	#we just turned it off, and we're in the editor, and the dimensions were (0, 0) before, the user probably doesn't actually want the thing to be (0, 0)
	if (not OverrideDimensions) and (Engine.editor_hint) and (SpriteDimensions == Vector2(0, 0)):
		#so just set it to the default scale
		scale = Vector2(1, 1)

func SetDimensions(newDimensions):
	SpriteDimensions = newDimensions
	
	if OverrideDimensions:
		scale = Vector2(SpriteDimensions.x / texture.get_width(), SpriteDimensions.y / texture.get_height())
