extends Node2D

var MixtureChecker: Resource

func _ready():
	MixtureChecker = load("res://MistakeCheckers/MixtureChecker.tres")
	if MixtureChecker != null:
		MixtureChecker.Mixtures = LoadMixtures()
	
func LoadMixtures() -> Dictionary:
	# Checking if file exists
	if not FileAccess.file_exists("res://mixtures.json"):
		push_error("Mixture file mixtures.json is missing! Cannot check user made mixtures!")
		return {}
	
	# Opening file
	var mixtureFile: FileAccess = FileAccess.open('res://mixtures.json', FileAccess.READ)
	
	# Checking if file is open 
	if mixtureFile == null:
		push_error("Mixture file mixtures.json failed to open!")
		return {}
	
	# Parse the file contents into a dictonary
	var parse_res: JSON = JSON.new()
	parse_res.parse(mixtureFile.get_as_text())
	
	# Checking for parsing errors
	if parse_res.error != OK:
		push_error("Error parsing JSON data from mixtures.json: " + str(parse_res.error))
		mixtureFile.close()
		return {}
		
	mixtureFile.close()
	return parse_res.get_data()
