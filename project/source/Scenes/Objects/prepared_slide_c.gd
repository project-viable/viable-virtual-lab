extends StaticBody2D

signal is_selected
var is_draggable: bool = false

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("click") and is_draggable:
		is_selected.emit(self, is_draggable)
	elif Input.is_action_just_released("click"):
		is_selected.emit(self, false)
		
func _on_mouse_entered() -> void:
	is_draggable = true


func _on_mouse_exited() -> void:
	is_draggable = false
