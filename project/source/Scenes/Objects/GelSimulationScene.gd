extends Node2D

var gel_band_scene = preload("res://Scenes/Objects/GelBandScene.tscn")
var bands = [[]]
var gel

func _init(in_gel):
	gel = in_gel

# Called when the node enters the scene tree for the first time.
func _ready():
	bands = generate_gel_bands(gel)

func generate_gel_bands(gel):
	for band in gel.calculate_positions():
		var gel_band = gel_band_scene.instance()
		gel_band.position = band
		add_child(gel_band)
		bands.append(gel_band)
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
