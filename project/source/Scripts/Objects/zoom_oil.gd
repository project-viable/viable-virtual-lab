extends Node2D
class_name ZoomOil
signal apply_oil(slide: DraggableMicroscopeSlide)  
@onready var drag_offset: Vector2 = Vector2.ZERO
var dragging: bool = false
var mouse_over: bool = false
var current_slide: DraggableMicroscopeSlide = null

func _ready() -> void:
	add_to_group("ZoomOil")
	var area: Area2D = $Area2D  # Assuming your Area2D is a direct child
	area.mouse_entered.connect(_on_mouse_entered)
	area.mouse_exited.connect(_on_mouse_exited)
	# Connect to area signals for detecting slides
	area.area_entered.connect(_on_area_entered)
	area.area_exited.connect(_on_area_exited)
	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)

func _on_mouse_entered() -> void:
	mouse_over = true

func _on_mouse_exited() -> void:
	mouse_over = false

func _on_area_entered(area: Area2D) -> void:
	# Check if the area is part of a slide
	if area.get_parent() is CharacterBody2D:
		current_slide = area.get_parent()

func _on_area_exited(area: Area2D) -> void:
	if current_slide == area.get_parent():
		current_slide = null

func _on_body_entered(body: Node2D) -> void:
	# Check if body is a slide
	if body is CharacterBody2D:
		current_slide = body

func _on_body_exited(body: Node2D) -> void:
	if current_slide == body:
		current_slide = null

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		# Only start dragging if mouse is over the oil bottle
		if event.pressed and mouse_over:
			dragging = true
			drag_offset = get_global_mouse_position() - global_position
		elif not event.pressed and dragging:
			dragging = false
			if current_slide != null:
				# Emit signal with the slide we're applying oil to
				apply_oil.emit(current_slide)

func _input_event(viewport: Viewport, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		dragging = true
		drag_offset = get_global_mouse_position() - global_position

func _process(delta: float) -> void:
	if dragging:
		global_position = get_global_mouse_position() - drag_offset
		if Input.is_action_just_released("click"):
			dragging = false
			if current_slide != null:
				# Emit signal with the slide we're applying oil to
				apply_oil.emit(current_slide)
