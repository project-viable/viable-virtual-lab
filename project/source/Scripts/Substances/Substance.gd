extends Node
class_name Substance

# This object models a substance that can be placed into containers and mixed
# with other substances to produce a result.

var color: Color = Color('#4bd87e') # dictates what color to display in the substance's container
var volume: float = 1 # volume is used as the default measure to keep consistency between solids and liquids
var density: float = 1.0 # used for calculating mass based on the volume

var total_run_time: int = 0 # used for calculating time ran under current

func init_mixed(parent_substances: Array[Substance]) -> void:
	# this function is called when the substance is created by mixing 
	# other substances together.
	
	# determine the new color of the substance from its parents
	var new_color: Variant = null
	for substance: Substance in parent_substances:
		var subst_color: Color = substance.get_properties()['color']
		
		if(new_color == null):
			new_color = subst_color
		else:
			new_color = new_color.blend(subst_color)
	
	color = new_color

func init_created(properties: Dictionary) -> void:
	# this function is called when the substance is created from a source container.
	if(properties.has('color')):
		color = properties['color']
	
	if(properties.has('volume')):
		volume = properties['volume']
	
	if(properties.has('density')):
		density = properties['density']

func get_volume() -> float:
	return volume

func set_volume(value: float) -> void:
	volume = value

func get_mass() -> float:
	return (volume * density)

func get_density() -> float:
	return density

func get_properties() -> Dictionary:
	return { 
		"color": color,
		"volume": volume,
		"density": density
	}
	
func heat(heat_time: float) -> void:
	pass

func chill(chill_time: float) -> void:
	pass
	
func run_current(voltage: float, time: float) -> void:
	pass

func GetMain() -> Node2D:
	return get_tree().current_scene

func GetCurrentModuleScene() -> Node2D:
	return get_tree().current_scene.current_module_scene

func ReportAction(objects_involved: Array, action_type: String, params: Dictionary) -> void:
	print("Reporting an action of type " + action_type + " involving " + str(objects_involved) + ". Params are " + str(params))
	
	#This function asks for these as arguments, and then manually adds them here, to remind/force you to provide them
	params['objects_involved'] = objects_involved
	params['action_type'] = action_type
	GetMain().CheckAction(params)
	GetCurrentModuleScene().CheckAction(params)
