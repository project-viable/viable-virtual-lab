extends SelectableComponent


static var _speeds: Array[float] = [1.0, 2.0, 5.0, 10.0, 100.0]


var _speed_index: int = 0


func get_interactions() -> Array[InteractInfo]:
	var infos: Array[InteractInfo] = []

	if _speed_index > 0:
		infos.append(InteractInfo.new(InteractInfo.Kind.SECONDARY, "Slow down time"))
	if _speed_index + 1 < len(_speeds):
		infos.append(InteractInfo.new(InteractInfo.Kind.PRIMARY, "Speed up time"))

	return infos

func start_interact(k: InteractInfo.Kind) -> void:
	match k:
		InteractInfo.Kind.PRIMARY: _speed_index += 1
		InteractInfo.Kind.SECONDARY: _speed_index -= 1

	LabTime.time_scale = _speeds[_speed_index]
