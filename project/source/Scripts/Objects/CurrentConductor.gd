@tool
extends Node2D
class_name CurrentConductor

var volts: float = 0.0
var time: float = 0.0 # in minutes

func _ready() -> void:
	pass
	
func GetVolts() -> float:
	return volts

func SetVolts(newVolts: float) -> void:
	if newVolts >= 0:
		volts = newVolts

func GetTime() -> float:
	return time
	
func SetTime(newTime: float) -> void:
	if time >= 0:
		time = newTime
