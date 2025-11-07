extends LineEdit

@export var power_supply: LabBody

func _on_voltage_line_edit_text_changed(new_text: String) -> void:
	var column: int = caret_column
	var filtered_text: String = ""
	
	# Only want numbers
	for c in new_text:
		if c.is_valid_int():
			filtered_text += c
		else: # Keep the caret in the same place if invalid int is inputted
			column -= 1

	text = filtered_text
	caret_column = column
	power_supply.volts = int(text)
