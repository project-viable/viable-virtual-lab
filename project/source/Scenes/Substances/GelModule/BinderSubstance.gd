extends "res://Scripts/Substances/Substance.gd"

# This represents the binder solution that makes up one part of the gel.

func _init():
	var properties = {
		'density': 1.2,
		'color': '#00cc66'
	}
	
	# call the superclass init
	init_created(properties)

func get_properties():
	return {
		"color": color,
		"volume": volume
	}

func heat(heatTime):
	pass
