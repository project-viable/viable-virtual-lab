tool
extends Node2D
class_name CurrentConductor

var volts = 0
var current = 0
var time = 0 # in minutes

func _ready():
	pass
	
func GetVolts():
	return volts

func SetVolts(newVolts):
	if newVolts >= 0:
		volts = newVolts

func GetCurrent():
	return current

func SetCurrent(newCurrent):
	if newCurrent >= 0:
		current = newCurrent
		
func GetTime():
	return time
	
func SetTime(newTime):
	if time >= 0:
		time = newTime
