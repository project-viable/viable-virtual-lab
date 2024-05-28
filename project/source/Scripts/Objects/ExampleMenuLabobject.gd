extends LabObject

func _ready():
	._ready() #like super() in other languages
	$Menu.hide()

func TryActIndependently():
	$Menu.visible = !$Menu.visible
	return true

func _on_RichTextLabel_meta_clicked(meta):
	OS.shell_open(str(meta))

func _on_CloseButton_pressed():
	$Menu.hide()

func _on_ColorPicker_color_changed(color):
	$Polygon2D.color = color
