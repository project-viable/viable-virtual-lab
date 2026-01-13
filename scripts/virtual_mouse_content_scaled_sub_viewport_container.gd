extends ContentScaledSubViewportContainer


func _ready() -> void:
	super()
	Cursor.virtual_mouse_moved.connect(_on_virtual_mouse_moved)


func _gui_input(e: InputEvent) -> void:
	if e is InputEventMouse and not (e is InputEventMouseMotion):
		e.position = _viewport.canvas_transform * Cursor.virtual_mouse_position
		_send_event_to_viewport(_xform_event(e))

# Fake mouse motion to trick the viewport into making control nodes work.
func _on_virtual_mouse_moved(old_pos: Vector2, new_pos: Vector2) -> void:
	var xformed_old_pos := _viewport.canvas_transform * old_pos
	var xformed_new_pos := _viewport.canvas_transform * new_pos

	var event := InputEventMouseMotion.new()
	event.position = xformed_new_pos
	event.relative = xformed_new_pos - xformed_old_pos

	_send_event_to_viewport(_xform_event(event))

func _xform_event(e: InputEvent) -> InputEvent:
	return e.xformed_by(Transform2D.IDENTITY.scaled((_viewport.size as Vector2) / size))
