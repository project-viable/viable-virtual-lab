extends LabObject

# Called when the node enters the scene tree for the first time.
func _ready():
	$ImagingMenu.hide()

func TryActIndependently():
	$ImagingMenu.visible = !$ImagingMenu.visible
	return true

func _on_RichTextLabel_meta_clicked(meta):
	OS.shell_open(str(meta))

func _on_CloseButton_pressed():
	$ImagingMenu.hide()

func slot_filled(slot, object):
	pass

func slot_emptied(slot, object):
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
