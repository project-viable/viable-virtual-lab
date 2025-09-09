extends UseComponent


signal volume_changed()


@export var volume: int = 50


func get_interactions(_area: InteractableArea) -> Array[InteractInfo]:
	var ints: Array[InteractInfo] = []

	if volume > 1:
		ints.append(InteractInfo.new(InteractInfo.Kind.ADJUST_LEFT, "Decrease volume"))
	if volume < 100:
		ints.append(InteractInfo.new(InteractInfo.Kind.ADJUST_RIGHT, "Increase volume"))
	
	return ints

func start_use(_area: InteractableArea, kind: InteractInfo.Kind) -> void:
	match kind:
		InteractInfo.Kind.ADJUST_LEFT: volume -= 1
		InteractInfo.Kind.ADJUST_RIGHT: volume += 1

	volume_changed.emit()
