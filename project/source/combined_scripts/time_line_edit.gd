extends LineEdit
@export var power_supply: LabBody

## Get individual number input
func _on_time_line_edit_text_changed(new_text: String) -> void:
	if power_supply.time_string_input.length() < 4 and new_text.is_valid_int():
		power_supply.time_string_input += new_text
	
	text = ""
	power_supply.update_timer_display()
	
func _on_editing_toggled(toggled_on: bool) -> void:
	var minutes: int = power_supply._time / 60
	var seconds: int = power_supply._time % 60
	
	if toggled_on:
		if minutes > 0:
			power_supply.time_string_input = "%d%02d" % [minutes, seconds]
		elif minutes == 0 and seconds > 0:
			power_supply.time_string_input = str(seconds)
		elif minutes == 0 and seconds == 0:
			power_supply.time_string_input = ""
	else:
		power_supply.time_string_input = str(minutes) + str(seconds)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_text_backspace") and has_focus():
		power_supply.time_string_input = power_supply.time_string_input.left(-1)
		power_supply.update_timer_display()
