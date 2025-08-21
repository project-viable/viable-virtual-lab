extends LineEdit
@export var power_supply: LabBody
func _on_voltage_line_edit_text_changed(new_text: String) -> void:
	var column: int = caret_column
	var filtered_text: String = ""
	
	for char in new_text:
		if char.is_valid_int():
			filtered_text += char
	
	text = filtered_text
	caret_column = column
	power_supply._volts = int(text)

func _on_voltage_line_edit_focus_exited() -> void:
	if text.is_empty():
		power_supply._update_volt_display()
