extends Camera2D

var baseMoveRate = 12.5 #the rate at which to move when zoom is 1.
onready var moveRate = baseMoveRate #we adjust the move rate to be visually constant when we zoom in or out
var zoomFactor = 1.1 #we multiple/divide the zoom.

var allowedAreaMargin = 500 #number of units beyond each labobject's position to allow to be visible

#these variables are used internally to handle clicking and dragging:
var dragging = false
var dragMousePosition

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var startPosition = get_global_position()
	
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
	
	#if we've moved, make sure we're in the allowed area
	if get_global_position() != startPosition:
		FixToAllowedArea()

#include every LabObject's position, and then add a margin around the outside.
func GetAllowedRect():
	var result = Rect2(0, 0, 0, 0)
	
	for labobject in get_tree().get_nodes_in_group("LabObjects"):
		result = result.expand(labobject.get_global_position())
	
	result = result.grow(allowedAreaMargin)
	
	return result

#converts the edges of the viewport to world coordinates, and then zooms/moves the camera to make sure the viewport rect is entirely within the allowed area
func FixToAllowedArea():
	FixZoom()
	FixPosition()

func FixZoom():
	var allowedArea = GetAllowedRect()
	
	var viewportStart = get_canvas_transform().affine_inverse() * get_viewport_rect().position
	var viewportSize = (get_canvas_transform().affine_inverse() * get_viewport_rect().end) - viewportStart
	var visibleWorldRect = Rect2(viewportStart, viewportSize)
	
	#print("allowed area: ")
	#print(allowedArea)
	#print("visible rect: ")
	#print(visibleWorldRect)
	
	#first adjust zoom, by checking that the siezes make it posible to fit within the allowed area
	var yScaleFactor = visibleWorldRect.size.y / allowedArea.size.y
	var xScaleFactor = visibleWorldRect.size.x / allowedArea.size.x
	var worstScaleFactor = max(yScaleFactor, xScaleFactor)
	
	if worstScaleFactor > 1:
		Zoom(1.0/worstScaleFactor)

func FixPosition():
	var allowedArea = GetAllowedRect()
	
	var viewportStart = get_canvas_transform().affine_inverse() * get_viewport_rect().position
	var viewportSize = (get_canvas_transform().affine_inverse() * get_viewport_rect().end) - viewportStart
	var visibleWorldRect = Rect2(viewportStart, viewportSize)
	
	var xAdjustment = 0
	if visibleWorldRect.end.x > allowedArea.end.x:
		xAdjustment = allowedArea.end.x - visibleWorldRect.end.x
	elif visibleWorldRect.position.x < allowedArea.position.x:
		xAdjustment = allowedArea.position.x - visibleWorldRect.position.x
	
	var yAdjustment = 0
	if visibleWorldRect.end.y > allowedArea.end.y:
		yAdjustment = allowedArea.end.y - visibleWorldRect.end.y
	elif visibleWorldRect.position.y < allowedArea.position.y:
		yAdjustment = allowedArea.position.y - visibleWorldRect.position.y
	
	global_position += Vector2(xAdjustment, yAdjustment)

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

func Zoom(factor):
	zoom = zoom * factor
	moveRate = moveRate * factor
	FixToAllowedArea()

#This function is called by the Main Scene. Read the documentation for that for why.
func ZoomIn():
	Zoom(1.0/zoomFactor)

#This function is called by the Main Scene. Read the documentation for that for why.
func ZoomOut():
	Zoom(zoomFactor)
