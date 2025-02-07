extends PopupMenu

func _on_sliderDispenseQty_value_changed(value: float) -> void:
	$PanelContainer/lblDispenseQty.text = str(value) + " g"

func _on_btnCancel_pressed() -> void:
	hide()
