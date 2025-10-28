## A class that stores the state of a gel after electricity has been ran through it.
## Things such as at what voltage and how long the electricity was ran if the electrodes were placed 
## correctly if the gel wells were flooded (or rather how full each well is) if the gel components' 
## concentrations are appropriate or if the gel cooled properly can all be stored in this dictionary.

class_name  GelState
extends Resource

## An enum that describes all the possible states the gel bands can appear as.
enum GelBandState {
	PERFECT_LONG,
	PERFECT_SHORT,
	DIFFUSED_LONG,
	DIFFUSED_SHORT,
	WAVY_LONG,
	WAVY_SHORT,
	SMEARED_LONG, 
	SMEARED_SHORT,
	BLANK
}
# Global gel data
@export var electrode_correct_placement: bool = true ## incorrect placement means bands will run backwards and bands will not be visible
@export var voltage: int = 120 ## voltage that is too high or low will result in no visible bands or diffused bands
@export var gel_concentration: float = 1.50 ## incorrect concentration (in percentage) will result in diffused bands
@export var gel_analysis_asap: bool = true ## gel not put in the imager right after electropohresis results in diffused bands
@export var correct_gel_temperature: bool = true ## incorrect gel temperature (not between 50-70 deg C) results in smeared bands
@export var correct_comb_placement: bool = true ## incorrect gel comb placement or damaged wells results in smiley/wavy bands or
									## dna remainig in the wells
@export var correct_gel_mixing: bool = true ## inconsistent gel density (not mixed well) resuls in smiley/wavy bands
@export var voltage_run_time: float = 20.0 ## in mintues if the voltage is run for too long or not long enough this will
							## result in gel bands that are distorted or fuzzy or not visible from running off
							##the gel
							
## Dictionary holding well-specific information for well 1
@export var well1: Dictionary = {
	"name": "well 1",
	"well_capacity": 5.0, 
	"dna_size": 25.0,
	"GelBandState": null
}

## Dictionary holding well-specific information for well 2
@export var well2: Dictionary = {
	"name": "well 2",
	"well_capacity": 5.0, 
	"dna_size": 25.0,
	"GelBandState": null
}

## Dictionary holding well-specific information for well 3
@export var well3: Dictionary = {
	"name": "well 3",
	"well_capacity": 5.0, 
	"dna_size": 25.0,
	"GelBandState": null
}

## Dictionary holding well-specific information for well 4
@export var well4: Dictionary = {
	"name": "well 4",
	"well_capacity": 5.0, 
	"dna_size": 25.0,
	"GelBandState": null
}

## Dictionary holding well-specific information for well 5
@export var well5: Dictionary = {
	"name": "well 5",
	"well_capacity": 5.0, 
	"dna_size": 25.0,
	"GelBandState": null
}

## Dictionary holding well-specific information for well 6
@export var well6: Dictionary = {
	"name": "well 6",
	"well_capacity": 5.0, 
	"dna_size": 25.0,
	"GelBandState": null
}
