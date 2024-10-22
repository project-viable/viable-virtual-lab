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
var outcomes = {
	['Substance', 'Substance'] : 'Substance'
}
var substance_folder = 'res://Scenes/Substances/'

func _ready():
	# ensure all outcome key arrays are sorted
	var keys = outcomes.keys()
	for key in keys:
		key.sort()

func mix(reactants):
	# check if this outcome is listed in the outcomes dictionary
	var check_array = []
	for reactant in reactants:
		check_array.append(reactant.name)
	check_array.sort() # all key arrays must be sorted, or matching will fail
	
	if(outcomes.has(check_array)):
		# load and create the new substance
		var result_name = outcomes[check_array]
		var result_ref = load(substance_folder + result_name + '.tscn')
		if(result_ref != null):
			var result = result_ref.instantiate()
			# Need to add to scene in order to be able to call MistakeChecker methods
			self.add_child(result)
			result.init_mixed(reactants)
			return result
	else:
		return null
