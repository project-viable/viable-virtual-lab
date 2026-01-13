extends LineEdit
@export var power_supply: LabBody

## Doesn't actually write to a line, but instead this is used to get user input
## Which in turn updates the Time display on the power supply

var text_input: String = "":
	set(value):
		text_input = value
		power_supply.time_string_input = text_input

## Get individual number input
func _on_time_line_edit_text_changed(new_text: String) -> void:
	if text_input.length() < 4 and new_text.is_valid_int():
		text_input += new_text
	
	text = ""
	
func _on_editing_toggled(_toggled_on: bool) -> void:
	var minutes: int = power_supply.time / 60
	var seconds: int = power_supply.time % 60
	
	# Account for special cases.
	# For example, a time of 01:05 should result in a string of 105
	# Or a time of 00:05 should result in a string being 5 and not 05, the 0 being from the minutes
	if minutes > 0:
		text_input = "%d%02d" % [minutes, seconds]
	elif seconds > 0:
		text_input = str(seconds)
	elif seconds == 0:
		text_input = ""

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_text_backspace") and has_focus():
		text_input = text_input.left(-1)
