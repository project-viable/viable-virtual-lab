extends Node2D

var mixture_checker: Resource

func _ready() -> void:
	mixture_checker = load("res://MistakeCheckers/MixtureChecker.tres")
	if mixture_checker != null:
		mixture_checker.Mixtures = load_mixtures()
	
func load_mixtures() -> Dictionary:
	# Checking if file exists
	if not FileAccess.file_exists("res://mixtures.json"):
		push_error("Mixture file mixtures.json is missing! Cannot check user made mixtures!")
		return {}
	
	# Opening file
	var mixture_file: FileAccess = FileAccess.open('res://mixtures.json', FileAccess.READ)
	
	# Checking if file is open 
	if mixture_file == null:
		push_error("Mixture file mixtures.json failed to open!")
		return {}
	
	# Parse the file contents into a dictonary
	var parse_res: JSON = JSON.new()
	
	# Checking for parsing errors
	if parse_res.parse(mixture_file.get_as_text()) != OK:
		push_error("Error parsing JSON data from mixtures.json: " + str(parse_res.error))
		mixture_file.close()
		return {}
		
	mixture_file.close()
	return parse_res.get_data()
