## Contains a set of substances and can be used to 
class_name ContainerComponent
extends Node2D


@export var environment: SubstanceEnvironment = SubstanceEnvironment.new()
@export var substances: Array[SubstanceInstance] = []


# Even when not actively being mixed, substances in a container will slowly diffuse.
const _base_mix_amount: float = 0.1
const _mix_amount_stagnation_rate: float = 0.1


func _physics_process(delta: float) -> void:
	for i in range(0, len(substances)):
		for j in range(0, len(substances)):
			if i == j: continue
			var new_substance := substances[j].mix_from(substances[i], environment, delta)
			if new_substance: substances[j] = new_substance
	
	_remove_empty_substances()

	environment.mix_amount = max(environment.mix_amount -_mix_amount_stagnation_rate * delta, _base_mix_amount)

# Increase the amount of turbulence in the container
func mix(amount: float) -> void:
	environment.mix_amount += amount

# `s` should be a copy.
func add(s: SubstanceInstance) -> void:
	var did_incorporate := false
	for substance in substances:
		if substance.try_incorporate(s):
			did_incorporate = true
			break

	if not did_incorporate:
		substances.append(s)

# Take the given volume from the first substance.
func take_volume(v: float) -> SubstanceInstance:
	if not substances: return SubstanceInstance.new()
	var result: SubstanceInstance = substances.front().take_volume(v)
	_remove_empty_substances()
	return result

func _remove_empty_substances() -> void:
	substances.assign(
		substances.filter(func(s: SubstanceInstance) -> bool: return s.get_volume() >= 0.00001))
