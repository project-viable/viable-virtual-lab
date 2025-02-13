extends Control
signal button_press(button_value: int)

@onready var buttons: Array[BaseButton] = ($"%4xButton".button_group).get_buttons()
@onready var button_values: Dictionary = {
	$"%4xButton": 4,
	$"%10xButton": 10,
	$"%20xButton": 20,
	$"%40xButton": 40,
	$"%100xButton": 100
} 

func _ready() -> void:
	for button: Button in buttons:
		button.pressed.connect(on_button_pressed.bind(button))
	
# Sends zoom values to ContenScreen Node
func on_button_pressed(button: Button) -> void:
	button_press.emit(button_values[button])
	
