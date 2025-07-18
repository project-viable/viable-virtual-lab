## A basic substance is in some way "pure". I.e., it's not composed of any other substances. This
## means that it can have homogeneous behavior (appearance, density, et cetera).
class_name BasicSubstance
extends SubstanceInstance

@export var data: BasicSubstanceData
@export var volume: float

# Don't duplicate `data`.
func clone() -> BasicSubstance: return duplicate(false)

func get_density() -> float: return data.density
func get_volume() -> float: return volume
func get_color() -> Color: return data.color

# Only incorporate the same substance.
func try_incorporate(s: SubstanceInstance) -> bool:
	if s is BasicSubstance and s.data.name == data.name:
		volume += s.volume
		return true
	else:
		return false

func take_volume(v: float) -> SubstanceInstance:
	var amount_to_take: float = clamp(v, 0.0, volume)
	var result := clone()
	result.volume = amount_to_take
	volume -= amount_to_take
	return result

# Used by `SolutionSubstance` to determine how quickly to mix this in.
func get_solubility(solvent: BasicSubstance) -> float:
	return data.solubilities.get(solvent.data.name, 0.0)
