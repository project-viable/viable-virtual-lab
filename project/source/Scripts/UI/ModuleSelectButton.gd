extends Button

var sceneToLoad

func SetData(data: ModuleData):
	text = data.Name
	hint_tooltip = data.Tooltip
	icon = data.Thumbnail #TODO: if this is not provided, the button is invisible. Have some default texture to use if Thumbnail is null?
	sceneToLoad = data.Scene
