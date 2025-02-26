extends Button

var scene_to_load: PackedScene

func set_data(data: ModuleData) -> void:
	text = data.name
	tooltip_text = data.Tooltip
	icon = data.Thumbnail #TODO: if this is not provided, the button is invisible. Have some default texture to use if Thumbnail is null?
	scene_to_load = data.Scene
