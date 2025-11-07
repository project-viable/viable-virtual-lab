extends UseComponent


# 0 is not pressed; 2 is fully pressed.
var stop: int = 0


func get_interactions(_a: InteractableArea) -> Array[InteractInfo]:
	return [
		InteractInfo.new(InteractInfo.Kind.SECONDARY, "Plunge to first stop"),
		InteractInfo.new(InteractInfo.Kind.TERTIARY, "Plunge to second stop")
	]

func start_use(_a: InteractableArea, _k: InteractInfo.Kind) -> void:
	stop += 1

func stop_use(_a: InteractableArea, _k: InteractInfo.Kind) -> void:
	stop -= 1
