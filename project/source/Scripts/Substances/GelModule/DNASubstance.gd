extends Substance
class_name DNASubstance

#export (Array) var particle_sizes = [1,1.3,1.7,3]
var particle_sizes: Array[float] = [1,1.3,1.7,3]

func _init() -> void:
	var properties := {
		'density': 1.2,
		'color': '#00cc66'
	}
	init_created(properties)

# TODO (update): This should really just be a constructor. If we made `Substance` derive from
# `Resource` instead, it might make stuff like this easier. No nodes should have to be instantiated
# to make a substance.
func initialize(input_particle_sizes: Array[float]) -> void:
	particle_sizes = input_particle_sizes

func get_particle_sizes() -> Array[float]:
	return particle_sizes

func get_properties() -> Dictionary:
	return {
		"color": color,
		"volume": volume
	}
