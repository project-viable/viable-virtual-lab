@tool
class_name DNASolutionSubstance
extends Substance


const MAX_FRAGMENT_SIZE := 15000.0
# We want it to take 20 minutes for the 15000 bp fragments to reach the end at 120 volts.
const RUN_TIME := 60.0 * 20.0
const VOLTAGE := 120.0
const RATE := 1.0 / log(MAX_FRAGMENT_SIZE) / VOLTAGE / RUN_TIME


## Maps fragment sizes to their data.
@export var fragments: Dictionary[int, DNAFragment] = {}


func get_volume() -> float:
	var v := 0.0
	for f: DNAFragment in fragments.values():
		v += f.volume
	return v

func get_color() -> Color:
	return Color(0.327, 0.481, 0.99, 0.737)

func try_incorporate(s: Substance) -> bool:
	if not (s is DNASolutionSubstance): return false

	for fs: int in s.fragments.keys():
		var s_fragment: DNAFragment = s.fragments[fs]
		var fragment: DNAFragment = fragments.get(fs)
		if fragment:
			fragment.volume += s_fragment.volume
		else:
			fragments.set(fs, s_fragment)

	return true

func take_volume(v: float) -> DNASolutionSubstance:
	var tot_volume := get_volume()
	if is_zero_approx(tot_volume): return DNASolutionSubstance.new()

	var proportion: float = clamp(v / tot_volume, 0.0, 1.0)

	var result: DNASolutionSubstance = clone()
	for fs: int in fragments.keys():
		fragments[fs].volume *= (1 - proportion)
		result.fragments[fs].volume *= proportion

	return result

func handle_event(e: Event) -> void:
	if e is GelMold.RunGelSubstanceEvent:
		# TODO: This should change based on the gel concentration.
		var gel_factor := 1.0
		for fs: int in fragments.keys():
			var fragment: DNAFragment = fragments[fs]
			fragment.position += e.gel.voltage * e.duration * gel_factor * log(float(fs)) * RATE
			fragment.position = clamp(fragment.position, 0.0, 1.0)
