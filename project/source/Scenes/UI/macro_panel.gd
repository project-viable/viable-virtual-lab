extends Control
signal button_press(button_value: int)

@onready var buttons: Array[BaseButton] = ($"%4xButton".button_group).get_buttons()
@onready var button_values: Dictionary = {
	$"%4xButton": "4x",
	$"%10xButton": "10x",
	$"%20xButton": "20x",
	$"%40xButton": "40x",
	$"%100xButton": "100x"
} 
func _ready() -> void:
	
	for button: Button in buttons:
		button.pressed.connect(on_button_pressed.bind(button))
	
# Sends zoom values to ContentScreen Node
func on_button_pressed(button: Button) -> void:
	button_press.emit(button_values[button])
	
