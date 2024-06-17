extends Node
class_name Substance

# This object models a substance that can be placed into containers and mixed
# with other substances to produce a result.

var color = Color('#4bd87e') # dictates what color to display in the substance's container
var volume = 1 # volume is used as the default measure to keep consistency between solids and liquids
var density = 1.0 # used for calculating mass based on the volume

func init_mixed(parent_substances):
	# this function is called when the substance is created by mixing 
	# other substances together.
	
	# determine the new color of the substance from its parents
	var new_color = null
	for substance in parent_substances:
		var subst_color = substance.get_properties()['color']
		
		if(new_color == null):
			new_color = subst_color
		else:
			new_color = new_color.blend(subst_color)
	
	color = new_color

func init_created(properties):
	# this function is called when the substance is created from a source container.
	if(properties.has('color')):
		color = properties['color']
	
	if(properties.has('volume')):
		volume = properties['volume']
	
	if(properties.has('density')):
		density = properties['density']

func get_volume():
	return volume

func set_volume(value):
	volume = value

func get_mass():
	return (volume * density)

func get_density():
	return density

func get_properties():
	return { 
		"color": color,
		"volume": volume,
		"density": density
	}

func GetCurrentModuleScene():
	return get_tree().current_scene.currentModuleScene
