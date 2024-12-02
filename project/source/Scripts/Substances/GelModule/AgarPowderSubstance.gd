extends "res://Scripts/Substances/Substance.gd"

# This represents the powdered agarose that makes up one part of the gel.

func _init() -> void:
<<<<<<< HEAD
	var properties:Dictionary = {
=======
	var properties: Dictionary = {
>>>>>>> d23adb1b6bb39a5004894396003ecb1aba517785
		'density': 1,
		'color': '#ffffff'
	}
	
	# call the superclass init
	init_created(properties)
