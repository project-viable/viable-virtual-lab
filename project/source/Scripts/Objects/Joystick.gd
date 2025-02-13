extends Area2D
#Could try doing this with a virtual joystick setup and having users click and then drag 

@onready var outer_area:CollisionShape2D = $CollisionShape2D
@onready var knob:Sprite2D = $JoystickKnobTemp
@onready var max_distance:float  = $CollisionShape2D.shape.radius

var click : bool = false

func _input_event(viewport: Viewport, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.is_pressed():
	#if event is InputEventScreenTouch:
		var dist:float = event.position.distance_to(outer_area.global_position)
		if not click:
			if dist < max_distance:
				click = true
		else:
			knob.position = Vector2(0,0)
			click = false

func _process(delta: float) -> void:
	if click:
		knob.global_position = get_global_mouse_position()
		
		#i was trying this code to see if i could control how far the knob
		#can move but it wasn't really working
		#knob.position = outer_area.position + (knob.position - outer_area.position).clamp(knob.position, outer_area.position)
func get_velocity() -> Vector2:
	var joystick_velocity:Vector2 = Vector2(0,0)
	joystick_velocity.x = knob.position.x / max_distance
	joystick_velocity.y = knob.position.y / max_distance
	
	return joystick_velocity
