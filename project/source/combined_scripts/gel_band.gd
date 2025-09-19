class_name GelBands
extends Resource

## A dictionary that stores the state of a gel after electricity has been ran through it
## Things such as at what voltage and how long the electricity was ran, if the electrodes were placed 
## correctly, if the gel wells were flooded (or rather, how full each well is), if the gel components' 
## concentrations are appropriate or if the gel cooled properly can all be stored in this dictionary.
@export var gel_state: Dictionary = {}

## This is the state of the UV light for when gel is being imaged.
@export var UV_state: bool = false

## (virtual) returns the UV light state. True = UV light was on during imaging. Flase = UV light was
## off when imaging.
func get_UV_state() -> bool: return UV_state

## (virtual) returns the gel's state.
func get_gel_state() -> Dictionary: return gel_state

## (virtual) called when gel is placed in the imager. This function accepts a dictionary of the
## gel's state and using these factors, a different sprite image will be shown. This can be determined
## via a switch case statment, matching appropriate sprite with a specific set of gel states.
##
## For example, if the regardless of the gel's state, if the UV_state is false, then, the gel image
## sprite should show a blank image. The same result can occur if the electrodes were placeed 
## backwards before running electricity through the gel. 
##
## Once a case has been matched, a sprite within a pop-up window showing the appropriate bands within 
## the gel can be made visible once the imager is done running. 
func image_results(gel_state: Dictionary, UV_state: bool) -> void: pass
