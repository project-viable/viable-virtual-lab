extends "res://Scripts/Substances/Substance.gd"

# This represents the powdered agarose that makes up one part of the gel.

func _init():
	var properties = {
		'density': 0.8,
		'color': '#ccffdd'
	}
	
	# call the superclass init
	init_created(properties)

func get_properties():
	return {
		"color": color,
		"volume": volume
	}
func heat(heatTime):
	LabLog.Warn("You didn't mix in some of the Agar after adding it to the flask. Gel won't form properly when heating.", false, false)
