extends Node
## Singleton that provides access to stuff connected to "lab time". Lab time affects the speed of
## the simulation, but it does *not* affect the speed of physics or animations, since speeding up
## physics or animations would be annoying.


# Initial time after midnight, in seconds.
const INITIAL_TIME_AFTER_MIDNIGHT: float = 60 * 60 * 9


## Multiplier on the rate that time passes in the simulation.
var time_scale: float = 1.0

## Current time, in seconds, after midnight when the simulation started. This does [i]not[/i]
## reset to zero after a day has passed.
var time_after_midnight: float = INITIAL_TIME_AFTER_MIDNIGHT


func _process(delta: float) -> void:
	time_after_midnight += delta * time_scale

func get_hour_of_day() -> float:
	return fmod(time_after_midnight / (60.0 * 60.0), 24.0)

func get_minute_of_hour() -> float:
	return fmod(time_after_midnight / 60.0, 60.0)

func get_second_of_minute() -> float:
	return fmod(time_after_midnight, 60.0)
