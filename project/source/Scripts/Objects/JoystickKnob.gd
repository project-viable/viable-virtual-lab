extends Sprite2D

@export var maxDragLength: float = 100 #Max length the joystick can be dragged out to 
@export var deadZone: float = 5

@onready var joystickParent: Node2D  = $".."

var buttonPressed : bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#Even if we change the size of the current joystick, the scale will be proportional
	maxDragLength * joystickParent.scale.x

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if buttonPressed:
		if get_global_mouse_position().distance_to(joystickParent.global_position) <= maxDragLength:
			global_position = get_global_mouse_position()
		else:
			#Even if the mouse is outside of the bounds of the max drag length, you can still 
			#control the joystick will still pressing down
			var angle: float = joystickParent.global_position.angle_to_point(get_global_mouse_position())
			global_position.x = joystickParent.global_position.x + cos(angle)*maxDragLength
			global_position.y = joystickParent.global_position.y + sin(angle)*maxDragLength
		##For debugging purposes so that you can know the vectoro of the joystick
		#calculateVector()
	else:
		#Joystick position resets when the user lets go
		global_position = lerp(global_position, joystickParent.global_position, delta*10)
		##For debugging purposes so that you can know the vectoro of the joystick
		#joystickParent.posVector = Vector2(0,0)
		#print(joystickParent.posVector)

##For debugging purposes so that you can know the vectoro of the joystick
#func calculateVector() -> void:
	#if abs(global_position.x - joystickParent.global_position.x) >= deadZone:
		#joystickParent.posVector.x = (global_position.x - joystickParent.global_position.x)/ maxDragLength
	#if abs(global_position.y - joystickParent.global_position.y) >= deadZone:
		#joystickParent.posVector.y = (global_position.y - joystickParent.global_position.y)/ maxDragLength

func _on_button_button_down() -> void:
	buttonPressed = true


func _on_button_button_up() -> void:
	buttonPressed =  false
