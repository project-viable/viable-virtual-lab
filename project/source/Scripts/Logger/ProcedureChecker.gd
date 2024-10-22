@tool
extends Node2D

@export var CheckStrategies : set = SetCheckStrategies

func CheckAction(params: Dictionary):
	for strategy in CheckStrategies:
		strategy.CheckAction(params)

func SetCheckStrategies(newVal):
	#This is how we force you to only actually add MistakeCheckers
	#Godot 4 makes this trivial
	#But Godot 3.5 won't let you export an array with a type hint of custom resources :(
	for item in newVal.duplicate(false):
		if not (item is MistakeChecker) and item != null:
			print("CheckStrategies should only contain MistakeCheckers. " + str(item) + " is not one.")
			newVal.erase(item)
	
	CheckStrategies = newVal
