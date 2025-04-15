extends CharacterBody2D
class_name DraggableMicroscopeSlide
# If the user closes the fridge, the slides will still persist outside
# Users can also store the slides back into the fridge
# Selects the slide to be dragged
@onready var scene_root: Node2D = get_tree().current_scene

signal is_selected

@export var slide_name: String = "" # Used to change the path to the cell image shown in the computer
@export var right_side_up: Texture
@export var right_side_up_oiled: Texture
@export var right_side_down: Texture
@export var right_side_down_oiled: Texture

@export var oiled_up: bool:
	set(value):
		oiled_up = value
		_update_texture()
		
@export var slide_orientation_up: bool:
	set(value):
		slide_orientation_up = value
		_update_texture()

var is_mouse_hovering: bool = false
var is_inside_fridge: bool = true
var original_parent: Node2D = null
var current_parent: Node2D = null
var initial_mouse_pos: Vector2
var is_dragging: bool = false


func _ready() -> void:
	slide_orientation_up = randi() % 2 == 0 # Randomize if slides are oriented correctly 
	original_parent = get_parent()
	current_parent = original_parent
	
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("click") and is_mouse_hovering:
		initial_mouse_pos = get_global_mouse_position()
		
	if Input.is_action_pressed("click") and is_mouse_hovering and get_global_mouse_position().distance_to(initial_mouse_pos) > 3:
		is_dragging = true
		is_selected.emit(self, is_dragging)
		
	elif Input.is_action_just_released("click") and is_mouse_hovering:
		is_dragging = false
		is_selected.emit(self, is_dragging)
		
		if get_global_mouse_position().distance_to(initial_mouse_pos) < 3: # User clicked, toggles orientation
			
			slide_orientation_up = !slide_orientation_up
	
		
		if not is_inside_fridge and current_parent == original_parent:
			current_parent = scene_root
			self.reparent(scene_root) # Keep slide outside of fridge even when it is closed
		elif is_inside_fridge and current_parent != original_parent:
			current_parent = original_parent
			self.reparent(original_parent) # Put the slide back into the fridge and when closed, the slide will not persist

func _on_mouse_entered() -> void:
	is_mouse_hovering = true

func _on_mouse_exited() -> void:
	is_mouse_hovering = false

func _update_texture() -> void:
	var sprite := $Sprite2D
	if slide_orientation_up:
		sprite.texture = right_side_up_oiled if oiled_up else right_side_up
	else:
		sprite.texture = right_side_down_oiled if oiled_up else right_side_down
