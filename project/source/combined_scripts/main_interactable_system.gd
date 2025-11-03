extends InteractableSystem


signal pressed_left()
signal pressed_right()
signal pressed_zoom_out()


func get_interactions() -> Array[InteractInfo]:
	return [
		InteractInfo.new(InteractInfo.Kind.LEFT, "Go left", true, false),
		InteractInfo.new(InteractInfo.Kind.RIGHT, "Go right", true, false),
		InteractInfo.new(InteractInfo.Kind.INSPECT, "Zoom out", true, false),
	]

func start_interact(kind: InteractInfo.Kind) -> void:
	match kind:
		InteractInfo.Kind.LEFT: pressed_left.emit()
		InteractInfo.Kind.RIGHT: pressed_right.emit()
		InteractInfo.Kind.INSPECT: pressed_zoom_out.emit()
