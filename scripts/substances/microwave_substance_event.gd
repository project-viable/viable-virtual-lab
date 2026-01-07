class_name MicrowaveSubstanceEvent
extends Substance.Event
## Event sent when a microwave heats a substance for an amount of time.


## Amount of time microwaved, in seconds (this is in lab time rather than real time).
var duration: float = 0.0


func _init(p_duration: float) -> void: duration = p_duration
