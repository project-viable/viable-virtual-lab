extends "res://Scripts/Substances/Substance.gd"

# This represents the powdered agarose that makes up one part of the gel.

func _init():
	var properties = {
		'density': 1,
		'color': '#ccffdd'
	}
	
	# call the superclass init
	init_created(properties)
