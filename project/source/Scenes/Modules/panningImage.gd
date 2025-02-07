extends Sprite2D

@export var speed:float = 100
@export var move:Vector2 = Vector2(0,0)

func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	move = Vector2(0,0)
	var joystick:RigidBody2D = $"Joystick"
	
	move = joystick.get_velocity()
	position += move * speed * delta
	pass
