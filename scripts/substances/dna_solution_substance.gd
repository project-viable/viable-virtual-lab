@tool
class_name DNASolutionSubstance
extends Substance


# Small fragment size, which should take `RUN_TIME` to move across the
const SMALL_FRAGMENT_SIZE := 100.0
# We want it to take 20 minutes for the 100 bp fragments to reach the end at 120 volts.
const RUN_TIME := 60.0 * 20.0
const VOLTAGE := 120.0
# We divide this by the log of the fragment size and multiply by the voltage, so at 120 volts and
# 100 bp, a fragment will take 20 minutes to move fully across the gel.
const RATE := log(SMALL_FRAGMENT_SIZE) / VOLTAGE / RUN_TIME


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
		# TODO: This should change based on the gel concentration.
		var gel_factor := 1.0
		for fs: int in fragments.keys():
			var fragment: DNAFragment = fragments[fs]
			fragment.position += e.gel.voltage * e.duration * gel_factor / log(float(fs)) * RATE
			fragment.position = clamp(fragment.position, 0.0, 1.0)

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
