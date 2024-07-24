extends PopupMenu

func _on_sliderDispenseQty_value_changed(value):
	$PanelContainer/lblDispenseQty.text = str(value) + " g"

func _on_btnCancel_pressed():
	hide()
