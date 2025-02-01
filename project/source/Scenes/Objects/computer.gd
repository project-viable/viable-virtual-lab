extends StaticBody2D

signal screen_click_signal()
var is_clicked: bool = false

# Emits a signal to the FlourescenceMicroscope Node, used to zoom into the computer screen
func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and not is_clicked:
		screen_click_signal.emit()
		is_clicked = true
