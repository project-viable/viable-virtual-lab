extends Node

# This object exists in the background of a module and provides a way to 
# centrally control substance mixing. It should be extended on a per-module 
# basis, with its outcomes dictionary determining the possible mixing results 
# in that specific module.
#
# [!] NOTE: The names of substances included in the outcomes dictionary will 
# be treated as relative to the substance_folder location. Be sure to override 
# the default value when extending this class for modules. [!]

# here, mixing two default substances yields another default substance
var outcomes: Dictionary = {
	['Substance', 'Substance'] : 'Substance'
}
var substance_folder: String = 'res://Scenes/Substances/'

func _ready() -> void:
	# ensure all outcome key arrays are sorted
	var keys: Array = outcomes.keys()
	for key: Array in keys:
		key.sort()

func mix(reactants: Array[Substance]) -> Substance:
	# check if this outcome is listed in the outcomes dictionary
	var check_array: Array[String] = []
	for reactant in reactants:
		check_array.append(reactant.name)
	check_array.sort() # all key arrays must be sorted, or matching will fail
	
	if(outcomes.has(check_array)):
		# load and create the new substance
		var result_name: String = outcomes[check_array]
		var result_ref: PackedScene = load(substance_folder + result_name + '.tscn')
		if(result_ref != null):
			var result := result_ref.instantiate()
			# Need to add to scene in order to be able to call MistakeChecker methods
			self.add_child(result)
			result.init_mixed(reactants)
			return result
	
	return null
