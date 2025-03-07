@tool
extends Node2D

@export var check_strategies: Array[MistakeChecker]

func check_action(params: Dictionary) -> void:
	for strategy in check_strategies:
		strategy.check_action(params)
