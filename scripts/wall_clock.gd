extends Node2D


# Initial time after midnight, in seconds.
const INITIAL_TIME: float = 60 * 60 * 9


var _cur_time: float = INITIAL_TIME
var _time_held: float = 0.0
var _is_held: bool = false


func _process(delta: float) -> void:
	_cur_time += delta * LabTime.time_scale

	$HourHand.rotation = 2.0 * PI * fmod(_cur_time / (60.0 * 60.0), 12.0) / 12.0
	$MinuteHand.rotation = 2.0 * PI * fmod(_cur_time / 60.0, 60.0) / 60.0
	$SecondHand.rotation = 2.0 * PI * floor(fmod(_cur_time, 60.0)) / 60.0

	_time_held += delta
	if _is_held:
		LabTime.time_scale = ease(_time_held / 3.0, 2.0) * 100.0 + 1.0

func _on_selectable_component_started_holding() -> void:
	_time_held = 0.0
	_is_held = true


func _on_selectable_component_stopped_holding() -> void:
	_is_held = false
	LabTime.time_scale = 1.0
