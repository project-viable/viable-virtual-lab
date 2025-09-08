extends UseComponent


signal rotated_left()
signal rotated_right()


func get_interactions(_area: InteractableArea) -> Array[InteractInfo]:
	return [
		InteractInfo.new(InteractInfo.Kind.ADJUST_LEFT, "Rotate left"),
		InteractInfo.new(InteractInfo.Kind.ADJUST_RIGHT, "Rotate right"),
	]

func start_use(_area: InteractableArea, kind: InteractInfo.Kind) -> void:
	match kind:
		InteractInfo.Kind.ADJUST_LEFT: rotated_left.emit()
		InteractInfo.Kind.ADJUST_RIGHT: rotated_right.emit()
