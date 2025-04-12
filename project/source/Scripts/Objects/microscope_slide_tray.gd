extends Sprite2D

@export var tray_closed: Texture
@export var tray_open_light_on: Texture
@export var slide_tray_left_open: Texture 
@export var slide_tray_right_open: Texture
@export var tray_open_light_off: Texture
var can_slide_mount: bool = false
var slide: DraggableMicroscopeSlide
signal mount_slide(slide: DraggableMicroscopeSlide)

var left_open: bool = false
var right_open: bool = false
var light_on: bool = false

func _ready() -> void:
	$left_area.connect("pressed", _on_area_input.bind("left"))
	$right_area.connect("pressed", _on_area_input.bind("right"))

	
func _process(delta: float) -> void:
	if can_slide_mount and slide :
		slide.global_position = $whole_area/CollisionShape2D.global_position	
		if light_on and not left_open and not right_open: # Tray needs to be closed
			mount_slide.emit(slide)
		else:
			mount_slide.emit(null)
	
func _on_area_input(side: String) -> void:
	if side == "left":
		left_open = !left_open
	else:
		right_open = !right_open
		
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
		
	if can_slide_mount and slide and (not left_open or not right_open):
		slide.hide()
	elif slide and (left_open or right_open):
		slide.show()
		
				


func _on_whole_area_body_entered(body: Node2D) -> void:
	if right_open and left_open:
		slide = body
		can_slide_mount = true
	else:
		can_slide_mount = false

func _on_whole_area_body_exited(body: Node2D) -> void:
		can_slide_mount = false
		mount_slide.emit(null)
		
func _update_light_switch_color() -> void:
	var light_switch: Sprite2D = get_node("../light_switch/Sprite2D")
	light_switch.modulate = Color.GREEN if light_on else Color.GRAY

func _on_light_switch_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		light_on = !light_on
		_update_light_switch_color()
		if right_open and left_open:
			if light_on:
				texture = tray_open_light_on
			else:
				texture = tray_open_light_off
