tool
extends Node2D
class_name MistakeChecker

func CheckAction(params: Array):
	MixChecker(params)
	HeatingChecker(params)
	ChillChecker(params)
	CurrentReversedChecker(params)
	PipetteDispenseChecker(params)
	DisposeChecker(params)

func MixChecker(params: Array) -> void:
	pass

func HeatingChecker(params: Array) -> void:
	pass
	
func ChillChecker(params: Array) -> void:
	pass

func CurrentReversedChecker(params: Array) -> void:
	pass
	
func PipetteDispenseChecker(params: Array) -> void:
	pass
	
func DisposeChecker(params: Array) -> void:
	pass
