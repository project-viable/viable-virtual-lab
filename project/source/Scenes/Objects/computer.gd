extends StaticBody2D

signal screen_click_signal()
var is_clicked: bool = false
@onready var joystick:Area2D = $"../Joystick"
@onready var direction:Vector2 = Vector2(0,0)

func _ready() -> void:
	$PopupControl.hide()

# Emits a signal to the FlourescenceMicroscope Node, used to zoom into the computer screen
func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and not is_clicked:
		screen_click_signal.emit()
		is_clicked = true
		

# Used for exiting the computer
func _on_exit_button_pressed() -> void:
	get_node("PopupControl").visible = false
	is_clicked = false


func _process(delta: float) -> void:
	var content_screen:Node2D = $"%ContentScreen"
	if joystick: direction = joystick.get_velocity()
	content_screen.direction = direction
