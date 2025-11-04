class_name DNASolutionSubstance
extends GenericSubstance


## Fragment size in base pairs.
@export var fragment_size: int = 1


# Used by the gel to keep track of the associated band in the gel.
var position: float = 0.0


func _init() -> void:
	name = "DNA"
	color = Color(0.327, 0.481, 0.99, 0.737)

func try_incorporate(s: SubstanceInstance) -> bool:
	if s is DNASolutionSubstance and s.fragment_size == fragment_size:
		volume += s.volume
		return true
	else:
		return false
