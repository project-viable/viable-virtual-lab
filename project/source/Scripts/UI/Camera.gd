extends Camera2D

var baseMoveRate: float = 12.5 #the rate at which to move when zoom is 1.
@onready var moveRate: float = baseMoveRate #we adjust the move rate to be visually constant when we zoom in or out
var zoomFactor: float = 1.1 #we multiple/divide the zoom.

var allowedAreaMargin: int = 500 #number of units beyond each labobject's position to allow to be visible

#these variables are used internally to handle clicking and dragging:
var dragging: bool = false
var dragMousePosition: Vector2

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var startPosition: Vector2 = get_global_position()
	
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
		var currentOffset: Vector2 = get_global_mouse_position() - dragMousePosition
		global_position = FixPosition(-currentOffset)
		
		if Input.is_action_just_released("DragCamera"):
			StopDragging()
	
	#if we've moved, make sure we're in the allowed area
	if get_global_position() != startPosition:
		FixToAllowedArea()

#include every LabObject's position, and then add a margin around the outside.
func GetAllowedRect() -> Rect2:
	var result: Rect2 = Rect2(0, 0, 0, 0)
	
	for labobject in get_tree().get_nodes_in_group("LabObjects"):
		result = result.expand(labobject.get_global_position())
	
	result = result.grow(allowedAreaMargin)
	
	return result

#converts the edges of the viewport to world coordinates, and then zooms/moves the camera to make sure the viewport rect is entirely within the allowed area
func FixToAllowedArea() -> void:
	FixZoom()
	global_position = FixPosition()

func FixZoom() -> void:
	var allowedArea: Rect2 = GetAllowedRect()
	
	var viewportStart: Vector2 = get_canvas_transform().affine_inverse() * get_viewport_rect().position
	var viewportSize: Vector2 = (get_canvas_transform().affine_inverse() * get_viewport_rect().end) - viewportStart
	var visibleWorldRect: Rect2 = Rect2(viewportStart, viewportSize)
	
	#first adjust zoom, by checking that the siezes make it posible to fit within the allowed area
	var yScaleFactor: float = visibleWorldRect.size.y / allowedArea.size.y
	var xScaleFactor: float = visibleWorldRect.size.x / allowedArea.size.x
	var worstScaleFactor: float = max(yScaleFactor, xScaleFactor)
	
	if worstScaleFactor > 1:
		Zoom(1.0/worstScaleFactor)

func FixPosition(offsetFromCurrentGlobalPos: Vector2 = Vector2(0, 0)) -> Vector2:
	#call with no (or default) argument to get the adjustment for the current position
	#call with other arguments to get the adjustment that would need to be made for a hypothetical global position.
	
	var allowedArea: Rect2 = GetAllowedRect()
	
	var viewportStart: Vector2 = get_canvas_transform().affine_inverse() * get_viewport_rect().position
	var viewportSize: Vector2 = (get_canvas_transform().affine_inverse() * get_viewport_rect().end) - viewportStart
	var visibleWorldRect: Rect2 = Rect2(viewportStart + offsetFromCurrentGlobalPos, viewportSize)
	
	var xAdjustment: int = 0
	if visibleWorldRect.end.x > allowedArea.end.x:
		xAdjustment = allowedArea.end.x - visibleWorldRect.end.x
	elif visibleWorldRect.position.x < allowedArea.position.x:
		xAdjustment = allowedArea.position.x - visibleWorldRect.position.x
	
	var yAdjustment: int = 0
	if visibleWorldRect.end.y > allowedArea.end.y:
		yAdjustment = allowedArea.end.y - visibleWorldRect.end.y
	elif visibleWorldRect.position.y < allowedArea.position.y:
		yAdjustment = allowedArea.position.y - visibleWorldRect.position.y
	
	return global_position + offsetFromCurrentGlobalPos + Vector2(xAdjustment, yAdjustment)

func Reset() -> void:
	position = Vector2(0, 0)
	zoom = Vector2(1, 1)
	moveRate = baseMoveRate

#Camera does not do this on it's own. When input happens, Main decides what should happen.
func StartDragging() -> void:
	dragging = true
	dragMousePosition = get_global_mouse_position()

func StopDragging() -> void:
	dragging = false

func Zoom(factor: float) -> void:
	zoom = zoom * factor
	moveRate = moveRate * factor
	FixToAllowedArea()

#This function is called by the Main Scene. Read the documentation for that for why.
func ZoomIn() -> void:
	Zoom(1.0/zoomFactor)

#This function is called by the Main Scene. Read the documentation for that for why.
func ZoomOut() -> void:
	Zoom(zoomFactor)
