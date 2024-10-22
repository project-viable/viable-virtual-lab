extends Node2D

var MixtureChecker

func _ready():
	MixtureChecker = load("res://MistakeCheckers/MixtureChecker.tres")
	if MixtureChecker != null:
		MixtureChecker.Mixtures = LoadMixtures()
	
func LoadMixtures() -> Dictionary:
	var mixtureFile = File.new()
	if not mixtureFile.file_exists("res://mixtures.json"):
		push_error("Mixture file mixtures.json is missing! Cannot check user made mixtures!")
		return {}
	mixtureFile.open('res://mixtures.json', File.READ)
	var test_json_conv = JSON.new()
	test_json_conv.parse(mixtureFile.get_as_text())
	var mixtures = test_json_conv.get_data()
		
	mixtureFile.close()
	return mixtures
