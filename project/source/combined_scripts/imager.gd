## This is the class description for the Imager object.
## The Imager will accept a electrophoresed gel sample and produce an image of the DNA sample bands.
class_name Imager
extends Resource

## A dictionary that stores the state of a gel after electricity has been ran through it
## Things such as at what voltage and how long the electricity was ran, if the electrodes were placed 
## correctly, if the gel wells were flooded (or rather, how full each well is), if the gel components' 
## concentrations are appropriate or if the gel cooled properly can all be stored in this dictionary.
## The gel state should be exported from the Gel class.
@export var gel_state: Dictionary = {
	"electrode_correct_placement": false, ## incorrect placement means bands will run backwards and badns will not be visible
	"voltage": 0.00, ## voltage that is too high or low will result in no visible bands or diffused bands
	"gel_concentration": 0.00, ## incorrect concentration will result in diffused bands
	"well_capacity": 0.00, ## if well is flooded, this will results in diffused bands
						   ## if well is not full enough, this will results in no visible bands
	"gel_analysis_asap": false, ## gel not put in the imager right after electropohresis results in diffused bands
	"correct_gel_temperature": false, ## incorrect gel temperature results in smeared bands
	"correct_comb_placement": false, ## incorrect gel comb placement or damaged wells results in smiley/wavy bands or
									## dna remainig in the wells
	"correct_gel_mixing": false, ## inconsistent gel density (not mixed well) resuls in smiley/wavy bands
	
	
}

## This is the state of the UV light for when gel is being imaged. [code]true[/code] = UV light was on during imaging. 
## [code]false[/code] = UV light was off when imaging.
var UV_state: bool = false

## (virtual) returns the UV light state. [code]true[/code] = UV light was on during imaging.
## [code]false[/code] = UV light was off when imaging.
func get_UV_state() -> bool: return UV_state

## (virtual) returns the gel's state.
func get_gel_state() -> Dictionary: return gel_state

## (virutal) called when the UV_state = [code]false[/code] and sets the visibility of the blank gel sprite to [code]true[/code].
func display_blank_gel_bands() -> void: pass

## (virtual) should be called by the on_gel_inserted function to display, or rather, set the visibility
## of a sprite to [code]true[/code] showing the gel bands corresponding with the specific gel state presented. This 
## function accepts a dictionary of the gel's state and using these factors, a different sprite image
## will be shown. This can be determined via a switch case statment, matching appropriate sprite with 
## a specific set of gel states. For example, if the regardless of the gel's state, if the UV_state is 
## [code]false[/code], then, the gel image sprite should show a blank image. The same result can occur if the 
## electrodes were placeed backwards before running electricity through the gel. 
func display_gel_bands(gel_state: Dictionary) -> void: pass

## (virtual) called when gel is placed in the imager. If the UV light was not turned on before imaging,
## the display_blank_gel_bands function is called. Otherwise, the display_gel_bands is called.
func on_gel_inserted(UV_state: bool) -> void: pass

## Once a case has been matched within the display_gel_bands function, and the user removes the gel from
## the imageer, a sprite will replace the original gel sprite showing the appropriate bands within 
## the gel.
func on_gel_removed() -> void: pass
