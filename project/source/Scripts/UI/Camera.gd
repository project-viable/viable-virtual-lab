extends Camera2D

var base_move_rate: float = 12.5 #the rate at which to move when zoom is 1.
@onready var move_rate: float = base_move_rate #we adjust the move rate to be visually constant when we zoom in or out
var zoom_factor: float = 1.1 #we multiple/divide the zoom.

var allowed_area_margin: int = 500 #number of units beyond each labobject's position to allow to be visible

#these variables are used internally to handle clicking and dragging:
var dragging: bool = false
var drag_mouse_position: Vector2

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var start_position: Vector2 = get_global_position()
	
	if Input.is_action_pressed("CameraLeft"):
		translate(Vector2(-move_rate, 0))
	if Input.is_action_pressed("CameraRight"):
		translate(Vector2(move_rate, 0))
	if Input.is_action_pressed("CameraUp"):
		translate(Vector2(0, -move_rate))
	if Input.is_action_pressed("CameraDown"):
		translate(Vector2(0, move_rate))
	
	#The camera cannot check for mouse input directly because of how input is handled. See docs for the Main Scene.
	
	if dragging:
		#adjust our position so the mouse is still at the same global coordinate in the scene
		var current_offset: Vector2 = get_global_mouse_position() - drag_mouse_position
		global_position = fix_position(-current_offset)
		
		if Input.is_action_just_released("DragCamera"):
			stop_dragging()
	
	#if we've moved, make sure we're in the allowed area
	if get_global_position() != start_position:
		fix_to_allowed_area()

#include every LabObject's position, and then add a margin around the outside.
func get_allowed_rect() -> Rect2:
	var result: Rect2 = Rect2(0, 0, 0, 0)
	
	for labobject in get_tree().get_nodes_in_group("LabObjects"):
		result = result.expand(labobject.get_global_position())
	
	result = result.grow(allowed_area_margin)
	
	return result

#converts the edges of the viewport to world coordinates, and then zooms/moves the camera to make sure the viewport rect is entirely within the allowed area
func fix_to_allowed_area() -> void:
	fix_zoom()
	global_position = fix_position()

func fix_zoom() -> void:
	var allowed_area: Rect2 = get_allowed_rect()
	
	var viewport_start: Vector2 = get_canvas_transform().affine_inverse() * get_viewport_rect().position
	var viewport_size: Vector2 = (get_canvas_transform().affine_inverse() * get_viewport_rect().end) - viewport_start
	var visible_world_rect: Rect2 = Rect2(viewport_start, viewport_size)
	
	#first adjust zoom, by checking that the siezes make it posible to fit within the allowed area
	var y_scale_factor: float = visible_world_rect.size.y / allowed_area.size.y
	var x_scale_factor: float = visible_world_rect.size.x / allowed_area.size.x
	var worst_scale_factor: float = max(y_scale_factor, x_scale_factor)
	
	if worst_scale_factor > 1:
		zoom_by_factor(1.0/worst_scale_factor)

func fix_position(offset_from_current_global_pos: Vector2 = Vector2(0, 0)) -> Vector2:
	#call with no (or default) argument to get the adjustment for the current position
	#call with other arguments to get the adjustment that would need to be made for a hypothetical global position.
	
	var allowed_area: Rect2 = get_allowed_rect()
	
	var viewport_start: Vector2 = get_canvas_transform().affine_inverse() * get_viewport_rect().position
	var viewport_size: Vector2 = (get_canvas_transform().affine_inverse() * get_viewport_rect().end) - viewport_start
	var visible_world_rect: Rect2 = Rect2(viewport_start + offset_from_current_global_pos, viewport_size)
	
	var x_adjustment: int = 0
	if visible_world_rect.end.x > allowed_area.end.x:
		x_adjustment = allowed_area.end.x - visible_world_rect.end.x
	elif visible_world_rect.position.x < allowed_area.position.x:
		x_adjustment = allowed_area.position.x - visible_world_rect.position.x
	
	var y_adjustment: int = 0
	if visible_world_rect.end.y > allowed_area.end.y:
		y_adjustment = allowed_area.end.y - visible_world_rect.end.y
	elif visible_world_rect.position.y < allowed_area.position.y:
		y_adjustment = allowed_area.position.y - visible_world_rect.position.y
	
	return global_position + offset_from_current_global_pos + Vector2(x_adjustment, y_adjustment)

func reset() -> void:
	position = Vector2(0, 0)
	zoom = Vector2(1, 1)
	move_rate = base_move_rate

#Camera does not do this on it's own. When input happens, Main decides what should happen.
func start_dragging() -> void:
	dragging = true
	drag_mouse_position = get_global_mouse_position()

func stop_dragging() -> void:
	dragging = false

func zoom_by_factor(factor: float) -> void:
	zoom = zoom * factor
	move_rate = move_rate * factor
	fix_to_allowed_area()

#This function is called by the Main Scene. Read the documentation for that for why.
func zoom_in() -> void:
	zoom_by_factor(1.0/zoom_factor)

#This function is called by the Main Scene. Read the documentation for that for why.
func zoom_out() -> void:
	zoom_by_factor(zoom_factor)
