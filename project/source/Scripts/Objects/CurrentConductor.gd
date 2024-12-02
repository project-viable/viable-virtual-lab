@tool
extends Node2D
class_name CurrentConductor

var volts = 0
var time = 0 # in minutes

func _ready():
	pass
	
func GetVolts():
	return volts

func SetVolts(newVolts):
	if newVolts >= 0:
		volts = newVolts

func GetTime():
	return time
	
func SetTime(newTime):
	if time >= 0:
		time = newTime
