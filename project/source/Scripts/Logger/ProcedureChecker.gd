@tool
extends Node2D

@export var CheckStrategies: Array[MistakeChecker]

func check_action(params: Dictionary) -> void:
	for strategy in CheckStrategies:
		strategy.check_action(params)
