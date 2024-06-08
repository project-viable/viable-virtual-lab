extends Camera2D

var moveRate = 12.5

#these variables are used internally to handle clicking and dragging:
var dragging = false
var dragMousePosition

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_pressed("CameraLeft"):
		translate(Vector2(-moveRate, 0))
	if Input.is_action_pressed("CameraRight"):
		translate(Vector2(moveRate, 0))
	if Input.is_action_pressed("CameraUp"):
		translate(Vector2(0, -moveRate))
	if Input.is_action_pressed("CameraDown"):
		translate(Vector2(0, moveRate))
	
	if dragging:
		#adjust our position so the mouse is still at the same global coordinate in the scene
		var currentOffset = get_global_mouse_position() - dragMousePosition
		global_position -= currentOffset
		
		if Input.is_action_just_released("DragCamera"):
			StopDragging()

func Reset():
	position = Vector2(0, 0)

#Camera does not do this on it's own. When input happens, Main decides what should happen.
func StartDragging():
	dragging = true
	dragMousePosition = get_global_mouse_position()

func StopDragging():
	dragging = false
