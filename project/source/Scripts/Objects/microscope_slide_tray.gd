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
	$right_area.connect("input_event", _on_area_input.bind("slide_tray_right_openright"))

func _on_area_input(_viewport: Viewport, event: InputEvent, _shape_idx: int, side: String) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		if side == "left":
			left_open = !left_open
		else:
			right_open = !right_open
			
		if right_open and left_open:
			#TODO: make light turn on and off
			#if light_on:
				#texture = tray_open_light_off
				#light_on = false
			#else:
				#texture = tray_open_light_on
				#light_on = true
			texture = tray_open_light_off
		elif right_open:
			texture = slide_tray_right_open
		elif left_open:
			texture = slide_tray_left_open
		else:
			texture = tray_closed
				
