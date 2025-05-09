extends Sprite2D

@export var tray_closed: Texture
@export var tray_open_light_on: Texture
@export var slide_tray_left_open: Texture
@export var slide_tray_right_open: Texture
@export var tray_open_light_off: Texture
@export var slide_tray_right_open_light_on: Texture
@export var slide_tray_left_open_light_on: Texture

var can_slide_mount: bool = false
var slide: DraggableMicroscopeSlide
signal mount_slide(slide: DraggableMicroscopeSlide)

var left_open: bool = false
var right_open: bool = false
var light_on: bool = false

func _ready() -> void:
	$left_area.pressed.connect(_on_area_input.bind("left"))
	$right_area.pressed.connect(_on_area_input.bind("right"))
	_update_display()

func _process(delta: float) -> void:
	if can_slide_mount and slide :
		slide.global_position = $whole_area/CollisionShape2D.global_position
		if not light_on and not left_open and not right_open: # Tray needs to be closed
			mount_slide.emit(slide)
		else:
			mount_slide.emit(null)

func _on_area_input(side: String) -> void:
	if slide and slide.is_mouse_hovering: # Prevent slide trays from being toggled if clicking on the slide while it's in the tray
		return

	if side == "left":
		left_open = !left_open
		if left_open:
			LabLog.log("Opened left microscope door", false, false)
		else:
			LabLog.log("Closed left microscope door", false, false)
	else:
		right_open = !right_open
		if right_open:
			LabLog.log("Opened right microscope door", false, false)
		else:
			LabLog.log("Closed right microscope door", false, false)

	_update_display()

	if can_slide_mount and slide and (not left_open or not right_open):
		slide.hide()
	elif slide and (left_open or right_open):
		slide.show()

func _on_whole_area_body_entered(body: Node2D) -> void:
	LabLog.log("Slide placed", false, false)
	if right_open and left_open:
		slide = body
		can_slide_mount = true
		LabLog.log("Slide can mount", false, false)
	else:
		LabLog.log("Slide cannot mount", false, false)
		can_slide_mount = false

func _on_whole_area_body_exited(body: Node2D) -> void:
		LabLog.log("Slide removed", false, false)
		can_slide_mount = false
		mount_slide.emit(null)

func _on_light_switch_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		light_on = !light_on

		if light_on:
			LabLog.log("Turned microscope light on", false, false)
		else:
			LabLog.log("Turned microscope light off", false, false)

		_update_display()

func _update_display() -> void:
	$"../light_switch/Sprite2D".modulate = Color.GREEN if light_on else Color.GRAY

	match [left_open, right_open, light_on]:
		[false, false, _]: texture = tray_closed
		[false, true, false]: texture = slide_tray_right_open
		[false, true, true]: texture = slide_tray_right_open_light_on
		[true, false, false]: texture = slide_tray_left_open
		[true, false, true]: texture = slide_tray_left_open_light_on
		[true, true, false]: texture = tray_open_light_off
		[true, true, true]: texture = tray_open_light_on
