class_name GenericSubstance
extends Substance
## Can be used for any generic substance that doesn't need any special behavior.

@export var name: String
@export var color: Color = Color.WHITE
@export_custom(PROPERTY_HINT_NONE, "suffix:g/mL") var density: float = 1.0
## Volume of a substance
@export_custom(PROPERTY_HINT_NONE, "suffix:mL") var volume: float
@export var viscosity: float = 0.0

# Don't duplicate `data`.
## See [method Substance.clone]
func clone() -> GenericSubstance: return duplicate(false)
## See [method Substance.get_density]
func get_density() -> float: return density
## See [method Substance.get_volume]
func get_volume() -> float: return volume
## See [method Substance.get_color]
func get_color() -> Color: return color

func get_viscosity() -> float: return viscosity

# Only incorporate the same substance.
## See [method Substance.try_incorporate]
func try_incorporate(s: Substance) -> bool:
	if s is GenericSubstance and s.name == name:
		volume += s.volume
		return true
	else:
		return false

## See [method Substance.take_volume]
func take_volume(v: float) -> Substance:
	var amount_to_take: float = clamp(v, 0.0, volume)
	var result := clone()
	result.volume = amount_to_take
	volume -= amount_to_take
	return result
