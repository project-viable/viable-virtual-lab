extends RigidBody2D
#Could try doing this with a virtual joystick setup and having users click and then drag 
var posVector : Vector2




# we could change this to extend LabObject but I don't know if
# we want to use that or not

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
