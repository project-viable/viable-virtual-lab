extends Node2D


var _time_held: float = 0.0
var _is_held: bool = false


func _process(delta: float) -> void:
	$HourHand.rotation = 2.0 * PI * LabTime.get_clock_hour() / 12.0
	$MinuteHand.rotation = 2.0 * PI * LabTime.get_clock_minute() / 60.0
	$SecondHand.rotation = 2.0 * PI * LabTime.get_clock_second() / 60.0

	_time_held += delta
	if _is_held:
		LabTime.time_scale = ease(_time_held / 3.0, 2.0) * 100.0 + 1.0

func _on_selectable_component_started_holding() -> void:
	_time_held = 0.0
	_is_held = true

func _on_selectable_component_stopped_holding() -> void:
	_is_held = false
	LabTime.time_scale = 1.0
