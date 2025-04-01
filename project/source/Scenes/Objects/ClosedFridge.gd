extends StaticBody2D

var is_open: bool = false
signal on_click(is_open: bool)

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and not is_open:
		is_open = true
		on_click.emit(is_open)
		
