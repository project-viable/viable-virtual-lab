extends Node


const CONFIG_FILE_PATH: String = "user://config"
const MAIN_SECTION_NAME: String = "config"


var resolution: Vector2i = Vector2i(1280, 720)
# Not a direct multiplier on mouse movement speed. This is a value between -1 and 1, inclusive, and
# a value of 0 should give a multiplier of 1, but otherwise, it's up to the `Cursor` singleton to
# decide what the multiplier should be based on that.
var mouse_sensitivity: float = 0.0


# None of these properties can be null; they must have a fixed type so [method load] can handle them
# properly.
var _saved_properties: Array[StringName] = [
	&"resolution",
	&"mouse_sensitivity",
]


func _enter_tree() -> void:
	load_from_file()

func _exit_tree() -> void:
	save_to_file()


## Save the current config state to the file [constant CONFIG_FILE_PATH].
func save_to_file() -> void:
	var file := ConfigFile.new()

	for prop in _saved_properties:
		file.set_value(MAIN_SECTION_NAME, prop, get(prop))

	file.save(CONFIG_FILE_PATH)


func load_from_file() -> void:
	var file := ConfigFile.new()
	
	if file.load(CONFIG_FILE_PATH) != OK:
		push_warning("Failed to open config file")

	for prop in _saved_properties:
		var cur_value: Variant = get(prop)
		var new_value: Variant = file.get_value(MAIN_SECTION_NAME, prop, cur_value)

		if typeof(new_value) != typeof(cur_value):
			push_warning("Config %s was of wrong type" % [prop])
		else:
			set(prop, new_value)
			print("Loaded config %s = %s" % [prop, new_value])
