# TODO: I think this should be "res://Scripts/Substances/GelModule/GelMixManager.gd but I need to confrim
extends MixManager

# This is the mix manager for the Gel Electrophoresis lab module.

func _ready() -> void:
	super()
	outcomes = {
		['AgarPowderSubstance', 'BinderSubstance'] : 'GelMixSubstance'
	}
	substance_folder = 'res://Scenes/Substances/GelModule/'
