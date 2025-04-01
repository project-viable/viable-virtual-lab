extends StaticBody2D

signal change_slide(slide: String)


func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		change_slide.emit("C1")
