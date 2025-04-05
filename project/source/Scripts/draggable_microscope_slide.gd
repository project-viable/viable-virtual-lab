extends CharacterBody2D

signal is_selected
var is_draggable: bool = false

var is_inside_fridge: bool = true

var scene_root: Node2D = get_tree().current_scene
var original_parent: Node2D = null
var current_parent: Node2D = null


func setup() -> void:
	original_parent = get_parent()
	current_parent = original_parent
	
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("click") and is_draggable:
		is_selected.emit(self, is_draggable)
	elif Input.is_action_just_released("click"):
		is_selected.emit(self, false)
		
		if not is_inside_fridge and current_parent == original_parent:
			current_parent = scene_root
			self.reparent(scene_root)
		elif is_inside_fridge and current_parent != original_parent:
			current_parent = original_parent
			self.reparent(original_parent)

func _on_mouse_entered() -> void:
	is_draggable = true

func _on_mouse_exited() -> void:
	is_draggable = false
