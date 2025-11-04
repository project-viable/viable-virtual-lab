class_name DNASolutionSubstance
extends GenericSubstance


const MAX_FRAGMENT_SIZE := 15000.0
# We want it to take 20 minutes for the 15000 bp fragments to reach the end at 120 volts.
const RUN_TIME := 60.0 * 20.0
const VOLTAGE := 120.0
const RATE := 1.0 / log(MAX_FRAGMENT_SIZE) / VOLTAGE / RUN_TIME


## Fragment size in base pairs.
@export var fragment_size: int = 1


# Used by the gel to keep track of the associated band in the gel. This is a value from 0 to 1,
# with 0 being the start of the gel and 1 being the end.
var position: float = 0.0


func get_color() -> Color: return Color(0.327, 0.481, 0.99, 0.737)

func try_incorporate(s: SubstanceInstance) -> bool:
	if s is DNASolutionSubstance and s.fragment_size == fragment_size:
		volume += s.volume
		return true
	else:
		return false

# [param gel_factor] linearly scales the movement based on how liquidy the gel is.
func run_voltage(voltage: float, time: float, gel_factor: float) -> void:
	position += voltage * time * gel_factor * log(float(fragment_size)) * RATE
	position = clamp(position, 0.0, 1.0)
