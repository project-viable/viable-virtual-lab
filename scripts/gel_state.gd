## A class that stores the state of a gel after electricity has been ran through it.
## Things such as at what voltage and how long the electricity was ran if the electrodes were placed 
## correctly if the gel wells were flooded (or rather how full each well is) if the gel components' 
## concentrations are appropriate or if the gel cooled properly can all be stored in this dictionary.

class_name  GelState
extends Resource

# Global gel data
@export var electrode_correct_placement: bool = false ## incorrect placement means bands will run backwards and bands will not be visible
@export_custom(PROPERTY_HINT_NONE, "suffix:V") var voltage: int = 0 ## voltage that is too high or low will result in no visible bands or diffused bands
@export_custom(PROPERTY_HINT_NONE, "suffix:%") var gel_concentration: float = 0.0 ## incorrect concentration (in percentage) will result in diffused bands
@export var gel_analysis_asap: bool = false ## gel not put in the imager right after electropohresis results in diffused bands
@export var correct_gel_temperature: bool = false ## incorrect gel temperature (not between 50-70 deg C) results in smeared bands
@export var correct_comb_placement: bool = false ## incorrect gel comb placement or damaged wells results in smiley/wavy bands or
									## dna remainig in the wells
@export var correct_gel_mixing: bool = false ## inconsistent gel density (not mixed well) resuls in smiley/wavy bands
@export_custom(PROPERTY_HINT_NONE, "suffix:min") var voltage_run_time: float = 0.0 ## in mintues if the voltage is run for too long or not long enough this will
							## result in gel bands that are distorted or fuzzy or not visible from running off
							##the gel
@export var well_capacities: Array[float] = [0.0,0.0,0.0,0.0,0.0] ## how full a well is in milliliters.

@export_custom(PROPERTY_HINT_NONE, "suffix:mL") var well_max_capacity: float = 0.005 ## the maximum volume in milliliters a well can hold
