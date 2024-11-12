@tool
extends Node2D

@export var CheckStrategies: Array[MistakeChecker]

func CheckAction(params: Dictionary) -> void:
	for strategy in CheckStrategies:
		strategy.CheckAction(params)
