extends Sprite2D

@export var tray_closed: Texture
@export var tray_open_light_on: Texture
@export var slide_tray_left_open: Texture 
@export var slide_tray_right_open: Texture
@export var tray_open_light_off: Texture

var left_open: bool = false
var right_open: bool = false
var light_on: bool = false

func _ready() -> void:
	$left_area.connect("input_event", _on_area_input.bind("left"))
	$right_area.connect("input_event", _on_area_input.bind("right"))

func _on_area_input(_viewport: Viewport, event: InputEvent, _shape_idx: int, side: String) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		if side == "left":
			left_open = !left_open
			if left_open:
				LabLog.log("Opened left microscope door", false, false)
			else:
				LabLog.log("Closed left microscope door", false, false)
		else:
			right_open = !right_open
			if left_open:
				LabLog.log("Opened right microscope door", false, false)
			else:
				LabLog.log("Closed right microscope door", false, false)
			
		if right_open and left_open:
			if light_on:
				texture = tray_open_light_on
			else:
				texture = tray_open_light_off
		elif right_open:
			texture = slide_tray_right_open
		elif left_open:
			texture = slide_tray_left_open
		else:
			texture = tray_closed
				

func _update_light_switch_color() -> void:
	var light_switch: Sprite2D = get_node("../light_switch/Sprite2D")
	light_switch.modulate = Color.GREEN if light_on else Color.GRAY

func _on_light_switch_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		light_on = !light_on
		if light_on:
			LabLog.log("Turned microscope light on", false, false)
		else:
			LabLog.log("Turned microscope light off", false, false)
		_update_light_switch_color()
		if right_open and left_open:
			if light_on:
				texture = tray_open_light_on
			else:
				texture = tray_open_light_off
