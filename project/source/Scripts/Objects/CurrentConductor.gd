@tool
extends Node2D
class_name CurrentConductor

var volts: float = 0.0
var time: float = 0.0 # in minutes

func _ready() -> void:
	pass
	
func GetVolts() -> float:
	return volts

func SetVolts(new_volts: float) -> void:
	if new_volts >= 0:
		volts = new_volts

func GetTime() -> float:
	return time
	
func SetTime(new_time: float) -> void:
	if time >= 0:
		time = new_time
