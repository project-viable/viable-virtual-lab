extends "res://Scripts/UI/MixManager.gd"

# This is the mix manager for the Gel Electrophoresis lab module.

func _ready():
	super()
	outcomes = {
		['AgarPowderSubstance', 'BinderSubstance'] : 'GelMixSubstance'
	}
	substance_folder = 'res://Scenes/Substances/GelModule/'
