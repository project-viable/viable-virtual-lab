extends UseComponent


signal volume_changed()


@export var volume: int = 50


## Subscene that this pipette is currently inside.
var containing_subscene: Subscene = null


func get_interactions(area: InteractableArea) -> Array[InteractInfo]:
	var ints: Array[InteractInfo] = []

	if volume > 1:
		ints.append(InteractInfo.new(InteractInfo.Kind.ADJUST_LEFT, "Decrease volume"))
	if volume < 100:
		ints.append(InteractInfo.new(InteractInfo.Kind.ADJUST_RIGHT, "Increase volume"))
	if area is SubsceneInteractableArea and area.subscene:
		ints.append(InteractInfo.new(InteractInfo.Kind.ZOOM, "Start injecting"))
	
	return ints

func start_use(area: InteractableArea, kind: InteractInfo.Kind) -> void:
	match kind:
		InteractInfo.Kind.ADJUST_LEFT:
			volume -= 1
			volume_changed.emit()
		InteractInfo.Kind.ADJUST_RIGHT:
			volume += 1
			volume_changed.emit()
		InteractInfo.Kind.ZOOM:
			Subscenes.active_subscene = area.subscene
			containing_subscene = area.subscene
