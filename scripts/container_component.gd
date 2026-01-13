@tool
class_name ContainerComponent
extends Node2D
## Contains a set of substances and can be used to hold them


## The array of substances to be held within the container
@export var substances: Array[Substance] = []

## Volume that this container can hold, in mL. The total volume of substances stored in this
## container is not prevented from going above this value; [member container_volume] exists mainly
## for things that want to display the contents of this container or implement custom overflow
## behavior.
@export_custom(PROPERTY_HINT_NONE, "suffix:mL") var container_volume: float = 1.0

## Mass of the container itself. This is not used when simulating, but it is used by the scale to
## calculate the total mass.
@export_custom(PROPERTY_HINT_NONE, "suffix:g") var container_mass: float = 0.0

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint(): return

	var lab_delta := delta * LabTime.time_scale

	# We need to duplicate the substance array because substances may modify the original one in
	# their `process` function.
	for s: Substance in substances.duplicate():
		s.process(self, lab_delta)

	_remove_empty_substances()

# `s` should be a copy.
## Adds a substance to the array of substances by adding it to an existing instance of the same
## substance or creates a new instance within the array.
func add(s: Substance) -> void:
	var did_incorporate := false
	for substance in substances:
		if substance.try_incorporate(s):
			did_incorporate = true
			break

	if not did_incorporate:
		substances.append(s)

## Add all substances in [param s].
func add_array(s: Array[Substance]) -> void:
	for substance in s: add(substance)

## Returns total volume in the container, in mL.
func get_total_volume() -> float:
	return substances.map(func(s: Substance) -> float: return s.get_volume()) \
			.reduce(func(a: float, b: float) -> float: return a + b, 0.0)

## Takes the given volume from the first substance.
func take_volume_from_back(v: float) -> Substance:
	if not substances: return DummySubstance.new()
	var result: Substance = substances.back().take_volume(v)
	_remove_empty_substances()
	return result

## Take at most [param v] mL of substances from the back of [member substances]. Return an array of
## the taken substances.
func take_volume(v: float) -> Array[Substance]:
	var result: Array[Substance] = []
	while v > 0 and substances:
		result.push_back(take_volume_from_back(v))
		v -= result.back().get_volume()
	return result

func get_substances_mass() -> float:
	var total_substance_mass: float = 0.0
	if !substances.is_empty():
		for substance in substances:
			total_substance_mass += (substance.get_density() * substance.get_volume())
		return total_substance_mass
	else:
		return 0.0

## Get the first substance in this container of type [param type]. If no such substance exists,
## return [code]null[/code].
func find_substance_of_type(type: Variant) -> Substance:
	var i := substances.find_custom(func(s: Substance) -> bool: return is_instance_of(s, type))
	if i == -1: return null
	else: return substances[i]

## Send an event to every substance in this container.
func send_event(event: Substance.Event) -> void:
	for s in substances: s.handle_event(event)

func _remove_empty_substances() -> void:
	substances.assign(
		substances.filter(func(s: Substance) -> bool: return s.get_volume() >= 0.00001))
