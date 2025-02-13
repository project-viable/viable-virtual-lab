extends Area2D
#Could try doing this with a virtual joystick setup and having users click and then drag 

@onready var outer_area:Sprite2D = $JoystickTemp
@onready var knob:Sprite2D = $JoystickKnobTemp
@onready var max_distance:float  = $CollisionShape2D.shape.radius

var click : bool = false

#func _input(event:InputEvent) -> void:
	#if event is InputEventScreenDrag:
		#var dist:float = event.position.distance_to(outer_area.global_position)
		#if not click:
			#if dist < max_distance:
				#click = true
		#else:
			#knob.position = Vector2(0,0)
			#click = false

func _process(delta: float) -> void:
	if click:
		if get_global_mouse_position().distance_to(outer_area.global_position) <= max_distance:
			global_position = get_global_mouse_position()
		else:
			#Even if the mouse is outside of the bounds of the max drag length, you can still 
			#control the joystick will still pressing down
			var angle: float = outer_area.global_position.angle_to_point(get_global_mouse_position())
			global_position.x = outer_area.global_position.x + cos(angle)*max_distance
			global_position.y = outer_area.global_position.y + sin(angle)*max_distance
		##For debugging purposes so that you can know the vectoro of the joystick
		#calculateVector()
	else:
		#Joystick position resets when the user lets go
		global_position = lerp(global_position, outer_area.global_position, delta*10)
	
	#if click:
		#knob.global_position = get_global_mouse_position()
		##knob.position = outer_area.position + (knob.position - outer_area.position).clamp(knob.position, outer_area.position)

func get_velocity() -> Vector2:
	var joystick_velocity:Vector2 = Vector2(0,0)
	joystick_velocity.x = knob.position.x / max_distance
	joystick_velocity.y = knob.position.y / max_distance
	
	return joystick_velocity

#func _ready() -> void:
	#pass
	#
#func _process(delta: float) -> void:
	#if Input.is_action_pressed("ui_right"):
		## just using 1 for now since i don't know how much it'll actually move yet
		## also not sure if we want pressing right = move right or if
		## we want press right = move left
		#position.x += 1
	#elif Input.is_action_just_pressed("ui_left"):
		#position.x -= 1
	#elif Input.is_action_just_pressed("ui_up"):
		## same with y-axis, press up = move up or press up = move down?
		#position.y += 1
	#elif Input.is_action_just_pressed("ui_down"):
		#position.y -= 1
		
# this is another way of doing the same thing but extending a 
# CharacterBody2D with an input map 
# Input Map:
# Left (physical), Right (physical), etc.

#
#@export var speed: int = 400
#
#func get_input() -> void:
	#var input_direction: Vector2 = Input.get_vector("left", "right", "up", "down")
	#velocity = input_direction * speed
	## not sure if anything needs to be exported here
	#
#
#func _physics_process(delta: float) -> void:
	#get_input()
	#move_and_slide()
