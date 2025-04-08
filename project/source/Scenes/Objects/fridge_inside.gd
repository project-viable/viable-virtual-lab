extends Node2D

var slide_script: Script = load("res://Scripts/draggable_microscope_slide.gd")
var currently_dragging: bool = false
var current_slide: CharacterBody2D = null

func _ready() -> void:
	var slides: Array = get_tree().get_nodes_in_group("Slides")
	for slide: CharacterBody2D in slides:
		slide.setup()
		slide.is_selected.connect(_on_slide_is_selected)

func _process(delta: float) -> void:
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and current_slide and currently_dragging:
		current_slide.global_position = get_global_mouse_position()

func _on_slide_is_selected(slide: CharacterBody2D, drag: bool) -> void:
	current_slide = slide
	currently_dragging = drag
