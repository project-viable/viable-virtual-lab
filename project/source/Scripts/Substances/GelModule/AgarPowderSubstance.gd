extends "res://Scripts/Substances/Substance.gd"

# This represents the powdered agarose that makes up one part of the gel.

func _init() -> void:
	var properties: Dictionary = {
		'density': 1,
		'color': '#ffffff'
	}
	
	# call the superclass init
	init_created(properties)
