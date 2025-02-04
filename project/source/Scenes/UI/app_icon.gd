extends StaticBody2D

signal app_click_signal()
var is_clicked: bool = false

# Emits a signal to switch to the main app
func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and not is_clicked:
		emit_signal("app_click_signal")
		is_clicked = true
		$CollisionShape2D.disconnect("_on_input_event", _on_input_event)
		$CollisionShape2D.disabled = true
