## A basic substance is in some way "pure". I.e., it's not composed of any other substances. This
## means that it can have homogeneous behavior (appearance, density, et cetera)
class_name BasicSubstance
extends SubstanceInstance

## data of a substance such as the name, color, density, and solubility.
@export var data: BasicSubstanceData
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
	if s is BasicSubstance and s.data.name == data.name:
		volume += s.volume
		return true
	else:
		return false
		
## See [method SubstanceInstance.process]
func process(container: ContainerComponent, delta: float) -> void:
	var is_soluble := func (s: SubstanceInstance) -> bool:
		return s is BasicSubstance and container.mix_amount * s.get_solubility(container, self) > 0.0

	# If anything is soluble in this, replace it with a solution substance with this as the
	# solvent. Without this, every substance that can dissolve something else would have to be
	# manually made into a `SolutionSubstance`.
	if container.substances.any(is_soluble):
		var i := container.substances.find(self)
		if i != -1:
			var solution := SolutionSubstance.new()
			solution.solvent = self
			container.substances[i] = solution
			solution.process(container, delta)

## See [method SubstanceInstance.take_volume]
func take_volume(v: float) -> SubstanceInstance:
	var amount_to_take: float = clamp(v, 0.0, volume)
	var result := clone()
	result.volume = amount_to_take
	volume -= amount_to_take
	return result

## Used by `SolutionSubstance` to determine how quickly to mix this in.
func get_solubility(container: ContainerComponent, solvent: BasicSubstance) -> float:
	var solubility_data: SolubilityData = data.solubilities.get(solvent.data.name)
	if not solubility_data or container.temperature < solubility_data.min_temp:
		return 0.0
	else:
		return solubility_data.base_solubility
