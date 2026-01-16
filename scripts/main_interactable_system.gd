extends InteractableSystem


signal pressed_left()
signal pressed_right()
signal pressed_zoom_out()


var can_zoom_out: bool = true


func get_interactions() -> Array[InteractInfo]:
	var result: Array[InteractInfo] = [
		InteractInfo.new(InteractInfo.Kind.LEFT, "Go left", true, false),
		InteractInfo.new(InteractInfo.Kind.RIGHT, "Go right", true, false),
	]

	if can_zoom_out:
		result.push_back(InteractInfo.new(InteractInfo.Kind.INSPECT, "Zoom out", true))

	return result

func start_interact(kind: InteractInfo.Kind) -> void:
	match kind:
		InteractInfo.Kind.LEFT: pressed_left.emit()
		InteractInfo.Kind.RIGHT: pressed_right.emit()
		InteractInfo.Kind.INSPECT: pressed_zoom_out.emit()
