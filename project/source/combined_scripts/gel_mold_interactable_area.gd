extends InteractableArea


signal zoomed()


func get_interactions() -> Array[InteractInfo]:
	if Interaction.held_body is Pipe:
		return [InteractInfo.new(InteractInfo.Kind.ZOOM, "Zoom in on gel")]
	else:
		return []

func start_interact(kind: InteractInfo.Kind) -> void:
	zoomed.emit()
