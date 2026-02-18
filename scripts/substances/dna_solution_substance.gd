@tool
class_name DNASolutionSubstance
extends Substance


const SMALL_FRAG_SIZE: float = 250
const BIG_FRAG_SIZE: float = 10000
const LOW_PERCENT: float = 0.01
const HIGH_PERCENT: float = 0.03

# Distances (as fractions of the length of the gel) traveled by small and big fragments in low
# and high concentration gels. I got these numbers by measuring the lengths on a random picture from
# the internet. We don't need the 2% high fragment size one, because these three are enough to
# solve.
const DIST_1PERC_SMALL: float = 10.0 / 11.0
const DIST_1PERC_BIG: float = 4.0 / 11.0
const DIST_2PERC_SMALL: float = 0.45 #6.5 / 11.0

# Solutions to system of equations ensuring the above distances will work. I did these on paper,
# so I don't feel like trying to explain these calculations in detail. At 1%, the agarose
# concentration factor should be exactly 1. You can see how these are used in `_handle_event` below,
# which handles the gel running.

# Rate that the time taken scales with the log of the fragment size.
const FRAG_SIZE_RATE: float = (1 / DIST_1PERC_BIG - 1 / DIST_1PERC_SMALL) / log(BIG_FRAG_SIZE / SMALL_FRAG_SIZE)
const FRAG_SIZE_BASE: float = 1 / DIST_1PERC_SMALL - log(SMALL_FRAG_SIZE) * FRAG_SIZE_RATE
# Rate that time taken scales with the agarose concentration.
const CONCENTRATION_RATE: float = (DIST_2PERC_SMALL * (FRAG_SIZE_BASE + FRAG_SIZE_RATE * log(SMALL_FRAG_SIZE)) - 1.0) / (1.0 / HIGH_PERCENT - 1.0 / LOW_PERCENT)
const CONCENTRATION_BASE: float = 1.0 - CONCENTRATION_RATE / LOW_PERCENT


# Time and voltage of a "normal" gel. We scale based on these.
const RUN_TIME := 60.0 * 20.0
const VOLTAGE := 120.0


## Evenly distribute the volumes in [member fragments] across the fragments. If any fragments are
## [code]null[/code], then they will be treated as having a volume of 0 and will automatically be
## generated.
@export_tool_button("Distribute Fragment Volumes", "Callable") var action_distribute_fragments: Callable = _distribute_fragments

## Remove fragment data from all fragments.
@export_tool_button("Clear Fragment Volumes", "Callable") var action_clear_fragment_data: Callable = _clear_fragment_data


## Maps fragment sizes to their data.
@export var fragments: Dictionary[int, DNAFragment] = {}


func get_volume() -> float:
	var v := 0.0
	for f: DNAFragment in fragments.values():
		# This should never be null at runtime, but it will temporarily be null when adding new
		# fragments in the editor.
		if f: v += f.volume
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
	if e is GelTray.RunGelSubstanceEvent:
		var gel_factor: float = CONCENTRATION_BASE + CONCENTRATION_RATE / e.gel_concentration
		# Scale directly with voltage.
		var voltage_factor: float = e.voltage / VOLTAGE
		# TODO: This should change based on the gel concentration.
		for fs: int in fragments.keys():
			var fragment: DNAFragment = fragments[fs]
			var frag_size_divisor := FRAG_SIZE_BASE + FRAG_SIZE_RATE * log(float(fs))
			var rate := gel_factor * voltage_factor / frag_size_divisor / RUN_TIME
			fragment.position += rate * e.duration
			#fragment.position = clamp(fragment.position, 0.0, 1.0)

func _distribute_fragments() -> void:
	if fragments.is_empty(): return

	var total_volume := get_volume()
	var average_volume := total_volume / fragments.size()

	for i: int in fragments.keys():
		var f := DNAFragment.new()
		f.volume = average_volume
		fragments[i] = f

	print("Distributed volume. Before: %s, After: %s" % [total_volume, get_volume()])

	notify_property_list_changed()

func _clear_fragment_data() -> void:
	for i: int in fragments.keys():
		fragments[i] = null
	notify_property_list_changed()
