class_name TAEBufferSubstance
extends SubstanceInstance
## This is the same as agarose.


const COOL_BASE_COLOR: Color = Color(0.0, 0.645, 0.86, 0.471)
const HOT_BASE_COLOR: Color = Color(0.989, 0.289, 0.506, 0.471)
const SATURATED_COLOR: Color = Color(0.94, 0.928, 0.921, 0.871)

const ROOM_TEMP: float = 20.0
# We want it to take about 20 seconds to mix in 1 gram of agarose powder.
const SECONDS_PER_GRAM_MIXED: float = 20.0
# 20 minutes to cool from 100°C to 20°C.
const COOL_TIME: float = 60.0 * 20.0
const COOL_RATE: float = (100.0 - ROOM_TEMP) / COOL_TIME
# 5 minutes to get from 20°C to 100°C.
const MICROWAVE_TIME: float = 60.0 * 5.0
const MICROWAVE_RATE: float = (100.0 - 20.0) / MICROWAVE_TIME


@export var volume: float = 0.0
## Concentration in g/mL.
@export var agarose_concentration: float = 0.0
## Temperature in °C.
@export var temperature: float = ROOM_TEMP


var is_mixing: bool = false


func get_density() -> float: return 1.08
func get_volume() -> float: return volume
func get_color() -> Color:
	var temp_t: float = clamp((temperature - ROOM_TEMP) / (100.0 - ROOM_TEMP), 0.0, 1.0)
	var base_color: Color = lerp(COOL_BASE_COLOR, HOT_BASE_COLOR, temp_t)
	var agar_t: float = clamp(agarose_concentration * 0.05, 0.0, 0.75)
	return lerp(base_color, SATURATED_COLOR, agar_t)


func take_volume(v: float) -> TAEBufferSubstance:
	var result: TAEBufferSubstance = clone()
	var volume_to_take: float = clamp(v, 0.0, volume)
	volume -= volume_to_take
	result.volume = volume_to_take
	return result

func try_incorporate(s: SubstanceInstance) -> bool:
	if s is TAEBufferSubstance:
		# TODO: Handle temperature and avoid divide by zero.
		agarose_concentration = \
			(agarose_concentration * volume + s.agarose_concentration * s.volume) \
			/ (volume + s.volume)
		volume += s.volume
		return true
	# Handle pipette too high above well. Just get rid of it.
	#elif s is DNASubstance:
	#	return true
	return false

func process(container: ContainerComponent, delta: float) -> void:
	temperature = max(temperature - COOL_RATE * delta, ROOM_TEMP)
	if volume <= 0: return
	for s in container.substances:
		if s is GenericSubstance:
			if temperature > 90 and is_mixing and s.name == "agarose":
				var agarose := s.take_volume(delta / s.get_density() / SECONDS_PER_GRAM_MIXED)
				agarose_concentration += agarose.get_volume() / agarose.get_density() / volume
		#elif s is DNASubstance:
		#	s.take_volume(INF)

# Microwave for [param time] seconds.
func microwave(time: float) -> void:
	temperature = min(100.0, temperature + MICROWAVE_RATE * time)
