extends SelectableComponent


var _is_held := false
var _time_held := 0.0


func _process(delta: float) -> void:
	_time_held += delta
	if _is_held:
		LabTime.time_scale = ease(_time_held / 3.0, 2.0) * 100.0 + 1.0

func get_interactions() -> Array[InteractInfo]:
	return [InteractInfo.new(InteractInfo.Kind.PRIMARY, "(hold) Speed up time")]

func start_interact(_k: InteractInfo.Kind) -> void:
	_time_held = 0.0
	_is_held = true

func stop_interact(_k: InteractInfo.Kind) -> void:
	_is_held = false
	LabTime.time_scale = 1.0
