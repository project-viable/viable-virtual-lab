@tool
extends Node2D
class_name CurrentConductor

var volts: float = 0.0
var time: float = 0.0 # in minutes

func _ready() -> void:
	pass
	
func get_volts() -> float:
	return volts

func set_volts(new_volts: float) -> void:
	if new_volts >= 0:
		volts = new_volts

func get_time() -> float:
	return time
	
func set_time(new_time: float) -> void:
	if time >= 0:
		time = new_time
