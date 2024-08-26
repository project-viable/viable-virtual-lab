extends "res://Scripts/Substances/Substance.gd"
class_name DNASubstance

#export (Array) var particle_sizes = [1,1.3,1.7,3]
var particle_sizes = [1,1.3,1.7,3]

func _init():
	var properties = {
		'density': 1.2,
		'color': '#00cc66'
	}
	init_created(properties)

func initialize(input_particle_sizes):
	particle_sizes = input_particle_sizes

func get_particle_sizes():
	return particle_sizes

func get_properties():
	return {
		"color": color,
		"volume": volume
	}
