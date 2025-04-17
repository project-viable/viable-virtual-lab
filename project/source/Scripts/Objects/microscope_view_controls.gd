extends LabObject

func lab_object_ready() -> void:
	$Border/Background/CloseButton.pressed.connect(_on_CloseButton_pressed)
	$Border.hide()

func try_act_independently() -> bool:
	$Border.visible = not $Border.visible
	return true

func _on_CloseButton_pressed() -> void:
	$Border.hide()
