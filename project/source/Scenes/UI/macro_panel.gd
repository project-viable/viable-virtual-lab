extends Control
signal zoom_value(zoom: String)

@export var button_group: ButtonGroup
@onready var button_values: Dictionary = {
	$"%10x": "10x",
	$"%20x": "20x",
	$"%40x": "40x",
	$"%100x": "100x"
} 
func _ready() -> void:
	var buttons: Array[BaseButton] = button_group.get_buttons()
	for button: Button in buttons:
		button.pressed.connect(on_button_pressed.bind(button))
	
# Sends zoom values to ContentScreen Node
func on_button_pressed(button: Button) -> void:
	var zoom: String = button_values[button]
	zoom_value.emit(zoom)
	
