extends Camera2D

var baseMoveRate = 12.5 #the rate at which to move when zoom is 1.
onready var moveRate = baseMoveRate #we adjust the move rate to be visually constant when we zoom in or out
var zoomFactor = 1.1 #we multiple/divide the zoom.

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
	
	#The camera cannot check for mouse input directly because of how input is handled. See docs for the Main Scene.
	
	if dragging:
		#adjust our position so the mouse is still at the same global coordinate in the scene
		var currentOffset = get_global_mouse_position() - dragMousePosition
		global_position -= currentOffset
		
		if Input.is_action_just_released("DragCamera"):
			StopDragging()

func Reset():
	position = Vector2(0, 0)
	zoom = Vector2(1, 1)
	moveRate = baseMoveRate

#Camera does not do this on it's own. When input happens, Main decides what should happen.
func StartDragging():
	dragging = true
	dragMousePosition = get_global_mouse_position()

func StopDragging():
	dragging = false

#This function is called by the Main Scene. Read the documentation for that for why.
func ZoomIn():
	zoom = zoom / zoomFactor
	moveRate = moveRate / zoomFactor

#This function is called by the Main Scene. Read the documentation for that for why.
func ZoomOut():
	zoom = zoom * zoomFactor
	moveRate = moveRate * zoomFactor
