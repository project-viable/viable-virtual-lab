@tool
class_name TAEBufferSubstance
extends Substance
## This is the same as agarose.


const COOL_BASE_COLOR: Color = Color(0.0, 0.645, 0.86, 0.471)
const HOT_BASE_COLOR: Color = Color(0.989, 0.289, 0.506, 0.471)
const SATURATED_COLOR: Color = Color(0.94, 0.928, 0.921, 0.871)

const ROOM_TEMP: float = 20.0
# Time it takes to get a gram of agarose to suspended (but not mixed) into the buffer. This must be
# shorter than the mix time to make sure some time is actually spent with the agarose visibly
# suspended (so it's clear that something is happening).
const SECONDS_PER_GRAM_SUSPENDED: float = 2.0
# We want it to take about 5 seconds to mix in 1 gram of agarose powder.
const SECONDS_PER_GRAM_MIXED: float = 5.0
# 20 minutes to cool from 100°C to 20°C.
const COOL_TIME: float = 60.0 * 20.0
const COOL_RATE: float = (100.0 - ROOM_TEMP) / COOL_TIME
# 1 minute to get from 20°C to 100°C.
const MICROWAVE_TIME: float = 60.0 * 1.0
# If we don't account for the cool rate, then the buffer will fail to reach the target temperature
# in the given time.
const MICROWAVE_RATE: float = (100.0 - 20.0) / MICROWAVE_TIME + COOL_RATE
# Maximum temperature to form a gel.
const GEL_TEMP: float = 40.0
# Minimum amount of agarose to form a solid gel.
const GEL_MIN_CONCENTRATION: float = 0.005
# Concentration of suspended agarose for full cloudiness.
const CLOUDY_SUSPENSION_CONCENTRATION: float = 0.005
const MIN_MIX_TEMP: float = 90


@export_custom(PROPERTY_HINT_NONE, "suffix:mL") var volume: float = 0.0
## Concentration of agarose suspended but not mixed.
@export_custom(PROPERTY_HINT_NONE, "suffix:g/mL") var suspended_agarose_concentration: float = 0.0
## Concentration in g/mL.
@export_custom(PROPERTY_HINT_NONE, "suffix:g/mL") var agarose_concentration: float = 0.0
## Temperature in °C.
@export_custom(PROPERTY_HINT_NONE, "suffix:°C") var temperature: float = ROOM_TEMP


var is_mixing: bool = false


func get_density() -> float: return 1.08
func get_volume() -> float: return volume
func get_color() -> Color:
	var temp_t: float = clamp((temperature - ROOM_TEMP) / (100.0 - ROOM_TEMP), 0.0, 1.0)
	var base_color: Color = lerp(COOL_BASE_COLOR, HOT_BASE_COLOR, temp_t)
	var agar_t: float = clamp(suspended_agarose_concentration / CLOUDY_SUSPENSION_CONCENTRATION , 0.0, 0.85)
	return lerp(base_color, SATURATED_COLOR, agar_t)

func get_viscosity() -> float:
	return clamp(agarose_concentration / 0.015, 0.0, 1.0) \
		* (1 - clamp((temperature - ROOM_TEMP) / (100.0 - ROOM_TEMP), 0.0, 1.0))

func take_volume(v: float) -> TAEBufferSubstance:
	var result: TAEBufferSubstance = clone()
	var volume_to_take: float = clamp(v, 0.0, volume)
	volume -= volume_to_take
	result.volume = volume_to_take
	return result

func try_incorporate(s: Substance) -> bool:
	if s is TAEBufferSubstance:
		# TODO: Handle temperature and avoid divide by zero.
		agarose_concentration = \
			(agarose_concentration * volume + s.agarose_concentration * s.volume) \
			/ (volume + s.volume)
		volume += s.volume
		return true
	# Handle pipette too high above well. Just get rid of it.
	elif s is DNASolutionSubstance:
		return true
	return false

func process(container: ContainerComponent, delta: float) -> void:
	temperature = max(temperature - COOL_RATE * delta, ROOM_TEMP)
	if volume <= 0: return
	for s in container.substances:
		if s is GenericSubstance:
			# TODO: The agarose should technically be suspended at any temperature (but not mixed),
			# but that would require a better way to visually show that the agarose is settling out
			# of the suspension instead of being mixed in when the temperature is too low. So we
			# just don't even let it get suspended when the temperature is too low.
			if temperature > MIN_MIX_TEMP and is_mixing and s.name == "agarose":
				var agarose := s.take_volume(delta / s.get_density() / SECONDS_PER_GRAM_SUSPENDED)
				suspended_agarose_concentration += agarose.get_volume() / agarose.get_density() / volume
		elif s is DNASolutionSubstance:
			s.take_volume(INF)

	# Mix in suspended agarose.
	if temperature > MIN_MIX_TEMP and is_mixing:
		var agarose_conc_to_mix: float = min(delta / SECONDS_PER_GRAM_MIXED / volume, suspended_agarose_concentration)
		suspended_agarose_concentration -= agarose_conc_to_mix
		agarose_concentration += agarose_conc_to_mix

func handle_event(e: Event) -> void:
	if e is MixSubstanceEvent:
		is_mixing = e.is_mixing
	elif e is MicrowaveSubstanceEvent:
		temperature = min(100.0, temperature + MICROWAVE_RATE * e.duration)

		Game.report_log.update_total(snapped(e.duration / 60, 0.01),"total_microwave_time")
		var microwave_data: String = "Gel heated for %s minutes" % [Game.report_log.report_data["total_microwave_time"]]
		Game.report_log.update_event(microwave_data, "microwave_time")
		var temperature_data: String = "Gel heated to %.f°C" % [temperature]
		Game.report_log.update_event(temperature_data, "gel_heated_temperature")
		Game.report_log.new_total(snapped(get_volume(), 0.01), "total_tae_in_gel")
		var tae_poured_data: String = str(Game.report_log.report_data["total_tae_in_gel"], " mL of TAE Buffer is in the gel")
		Game.report_log.update_event(tae_poured_data, "poured_tae_in_gel")

## True if this has enough agarose and is cool enough to be a gel that can maintain wells.
func is_solid_gel() -> bool:
	return temperature <= GEL_TEMP and agarose_concentration >= GEL_MIN_CONCENTRATION
