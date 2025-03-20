extends Sprite2D

@export var max_drag_length: float = 100 #Max length the joystick can be dragged out to 
@export var deadzone: float = 5

@onready var joystick_parent: Sprite2D  = $"../JoystickFinal"

var button_pressed : bool = false

#TODO: Consider deleting this Script
# Called when the node enters the scene tree for the first time.
#func _ready() -> void:
	##Even if we change the size of the current joystick, the scale will be proportional
	#max_drag_length * joystick_parent.scale.x

## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#if button_pressed:
		#if get_global_mouse_position().distance_to(joystick_parent.global_position) <= max_drag_length:
			#global_position = get_global_mouse_position()
		#else:
			##Even if the mouse is outside of the bounds of the max drag length, you can still 
			##control the joystick will still pressing down
			#var angle: float = joystick_parent.global_position.angle_to_point(get_global_mouse_position())
			#global_position.x = joystick_parent.global_position.x + cos(angle)*max_drag_length
			#global_position.y = joystick_parent.global_position.y + sin(angle)*max_drag_length
		###For debugging purposes so that you can know the vectoro of the joystick
		##calculateVector()
	#else:
		##Joystick position resets when the user lets go
		#global_position = lerp(global_position, joystick_parent.global_position, delta*10)
		###For debugging purposes so that you can know the vectoro of the joystick
		##joystick_parent.posVector = Vector2(0,0)
		#print(joystick_parent.posVector)

##For debugging purposes so that you can know the vectoro of the joystick
#func calculateVector() -> void:
	#if abs(global_position.x - joystick_parent.global_position.x) >= deadzone:
		#joystick_parent.posVector.x = (global_position.x - joystick_parent.global_position.x)/ max_drag_length
	#if abs(global_position.y - joystick_parent.global_position.y) >= deadzone:
		#joystick_parent.posVector.y = (global_position.y - joystick_parent.global_position.y)/ max_drag_length

#func _on_button_button_down() -> void:
	#button_pressed = true
#
#func _on_button_button_up() -> void:
	#button_pressed =  false
	
#func get_velocity() -> Vector2:
	#var joystick_velocity:Vector2 = Vector2(0,0)
	#joystick_velocity.x = joystick_parent.global_position.x / max_drag_length
	#joystick_velocity.y = joystick_parent.global_position.y / max_drag_length
	#
	#return joystick_velocity
	
