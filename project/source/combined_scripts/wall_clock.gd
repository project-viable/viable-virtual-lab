extends Node2D


# Initial time after midnight, in seconds.
const INITIAL_TIME: float = 60 * 60 * 9


var _cur_time: float = INITIAL_TIME


func _process(delta: float) -> void:
	_cur_time += delta * LabTime.time_scale

	$HourHand.rotation = 2.0 * PI * fmod(_cur_time / (60.0 * 60.0), 12.0) / 12.0
	$MinuteHand.rotation = 2.0 * PI * fmod(_cur_time / 60.0, 60.0) / 60.0
	$SecondHand.rotation = 2.0 * PI * floor(fmod(_cur_time, 60.0)) / 60.0
