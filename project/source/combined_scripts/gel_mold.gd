extends LabBody


enum Direction
{
	FRONT = 0b00,
	RIGHT = 0b01,
	BACK = 0b10,
	LEFT = 0b11,
}


@export var direction: Direction = Direction.LEFT
@export var closeup: GelCloseup


func _ready() -> void:
	super()
	_update_sprite()

func _on_use_component_rotated_left() -> void:
	direction += 3
	direction %= 4
	_update_sprite()
	print("Rotating gel left")

func _on_use_component_rotated_right() -> void:
	direction += 1
	direction %= 4
	_update_sprite()
	print("Rotating gel right")

func _update_sprite() -> void:
	for n in $SelectableCanvasGroup.get_children():
		n.hide()

	var sprite: Sprite2D = $%SideTexture if (direction & 0b01) == 1 else $%FrontTexture
	var flip := (direction & 0b10) == 0

	sprite.show()
	sprite.scale.x = -0.2 if flip else 0.2
