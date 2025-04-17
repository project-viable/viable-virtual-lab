extends LabObject

func lab_object_ready() -> void:
	$Border.hide()

func try_act_independently() -> bool:
	$Border.visible = not $Border.visible
	return true
