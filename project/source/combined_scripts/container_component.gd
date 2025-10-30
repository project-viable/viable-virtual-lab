## Contains a set of substances and can be used to hold them
class_name ContainerComponent
extends Node2D


## The array of substances to be held within the container
@export var substances: Array[SubstanceInstance] = []

## Temperature in °C. For simplicity, it is assumed that an entire container is always in thermal
## equilibrium.
@export var temperature: float = 20.0

## The amount of "mixiness" of the stuff in the container. This approximately corresponds with mass
## diffusivity, but is not given in any particular units. Substances can use this to determine how
## quickly to mix or perform reactions. Like temperature, this is *also* considered to be
## homogeneous throughout the container.
@export var mix_amount: float = _base_mix_amount

## Volume that this container can hold, in mL. The total volume of substances stored in this
## container is not prevented from going above this value; [member container_volume] exists mainly
## for things that want to display the contents of this container or implement custom overflow
## behavior.
@export var container_volume: float = 1.0

## Mass of the container itself. This is not used when simulating, but it is used by the scale to
## calculate the total mass.
@export var container_mass: float = 0.0

# Even when not actively being mixed, substances in a container will slowly diffuse.
const _base_mix_amount: float = 0.1
const _mix_amount_stagnation_rate: float = 0.1
const _temp_equalizing_rate: float = 0.1
const _room_temperature: float = 20.0


func _physics_process(delta: float) -> void:
	var lab_delta := delta * LabTime.time_scale

	# We need to duplicate the substance array because substances may modify the original one in
	# their `process` function.
	for s: SubstanceInstance in substances.duplicate():
		s.process(self, lab_delta)
	
	_remove_empty_substances()

	mix_amount = max(mix_amount -_mix_amount_stagnation_rate * lab_delta, _base_mix_amount)

	## Move the temperature towards room temperature
	if temperature < _room_temperature:
		temperature = min(temperature + _temp_equalizing_rate * lab_delta, _room_temperature)
	else:
		temperature = max(temperature - _temp_equalizing_rate * lab_delta, _room_temperature)

## Increase the amount of turbulence in the container
func mix(amount: float) -> void: mix_amount += amount

# `s` should be a copy.
## Adds a substance to the array of substances by adding it to an existing instance of the same 
## substance or creates a new instance within the array.
func add(s: SubstanceInstance) -> void:
	var did_incorporate := false
	for substance in substances:
		if substance.try_incorporate(s):
			did_incorporate = true
			break

	if not did_incorporate:
		substances.append(s)

## Returns total volume in the container, in mL.
func get_total_volume() -> float:
	return substances.map(func(s: SubstanceInstance) -> float: return s.get_volume()) \
			.reduce(func(a: float, b: float) -> float: return a + b, 0.0)

## Takes the given volume from the first substance.
func take_volume(v: float) -> SubstanceInstance:
	if not substances: return SubstanceInstance.new()
	var result: SubstanceInstance = substances.back().take_volume(v)
	_remove_empty_substances()
	return result

func _remove_empty_substances() -> void:
	substances.assign(
		substances.filter(func(s: SubstanceInstance) -> bool: return s.get_volume() >= 0.00001))

func get_substances_mass() -> float:
	var total_substance_mass: float = 0.0
	if !substances.is_empty():
		for substance in substances:
			total_substance_mass += (substance.get_density() * substance.get_volume())
		return total_substance_mass
	else:
		return 0.0
		
