## Substance consisting of a solution of multiple solutes in a single solvent.
class_name SolutionSubstance
extends SubstanceInstance


@export var solvent: BasicSubstance = BasicSubstance.new()
@export var solutes: Array[BasicSubstance] = []


func clone() -> SolutionSubstance:
	var result := SolutionSubstance.new()
	result.solvent = solvent.clone()
	result.solutes.assign(solutes.map(func(s: BasicSubstance) -> BasicSubstance: return s.clone()))
	return result

func get_density() -> float:
	var total_volume := get_volume()

	# If this has no volume, then it's essentially pure solvent, so it "makes sense" to use the
	# solvent's density instead of calculating it.
	if total_volume < 0.00001: return solvent.get_density()

	var density := solvent.get_density() * solvent.get_volume() / total_volume
	for solute in solutes:
		density += solute.get_density() * solute.get_volume() / total_volume

	return density

# We make the simplifying assumption that a solution has the same volume as its solvent.
func get_volume() -> float: return solvent.get_volume()

# For simplicity, we just do a weighted sum of the component colors.
func get_color() -> Color:
	var total_volume := solvent.get_volume()
	for s in solutes: total_volume += s.get_volume()

	if total_volume < 0.00001: return solvent.get_color()

	var color := solvent.get_color() * solvent.get_volume() / total_volume
	for solute in solutes:
		color += solute.get_color() * solute.get_volume() / total_volume

	return color

func try_incorporate(s: SubstanceInstance) -> bool:
	if not (s is SolutionSubstance) or not solvent.try_incorporate(s.solvent): return false
	for other_solute: BasicSubstance in s.solutes: add_solute(other_solute)
	return true

# We can only mix in basic substances that are soluble.
func mix_from(s: SubstanceInstance, env: SubstanceEnvironment, delta: float) -> SubstanceInstance:
	if not (s is BasicSubstance): return null
	var amount_to_take: float = delta * env.mix_amount * s.get_solubility(solvent)
	if amount_to_take < 0.00001: return null
	add_solute(s.take_volume(amount_to_take))
	return null

# Will take an even ratio of the solvent and solutes.
func take_volume(v: float) -> SolutionSubstance:
	var result := clone()
	var total_volume := get_volume()
	if total_volume < 0.00001: return result

	var amount_to_take: float = clamp(v, 0.0, total_volume)
	var ratio := amount_to_take / total_volume

	result.solvent.volume = ratio * solvent.volume
	solvent.volume -= result.solvent.volume
	for i in range(0, len(solutes)):
		result.solutes[i].volume = ratio * solutes[i].volume
		solutes[i].volume -= result.solutes[i].volume
	
	return result

# `s` must be a copy.
func add_solute(s: BasicSubstance) -> void:
	var did_incorporate := false
	for solute in solutes:
		if solute.try_incorporate(s):
			did_incorporate = true
			break

	if not did_incorporate: solutes.append(s)
