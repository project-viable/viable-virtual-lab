class_name GenericSubstance
extends SubstanceInstance
## Can be used for any generic substance that doesn't need any special behavior.

@export var name: String
@export var color: Color = Color.WHITE
@export var density: float = 1.0
## Volume of a substance
@export var volume: float

# Don't duplicate `data`.
## See [method SubstanceInstance.clone]
func clone() -> BasicSubstance: return duplicate(false)
## See [method SubstanceInstance.get_density]
func get_density() -> float: return data.density
## See [method SubstanceInstance.get_volume]
func get_volume() -> float: return volume
## See [method SubstanceInstance.get_color]
func get_color() -> Color: return data.color

# Only incorporate the same substance.
## See [method SubstanceInstance.try_incorporate]
func try_incorporate(s: SubstanceInstance) -> bool:
	if s is BasicSubstance and s.name == name:
		volume += s.volume
		return true
	else:
		return false

## See [method SubstanceInstance.take_volume]
func take_volume(v: float) -> SubstanceInstance:
	var amount_to_take: float = clamp(v, 0.0, volume)
	var result := clone()
	result.volume = amount_to_take
	volume -= amount_to_take
	return result
