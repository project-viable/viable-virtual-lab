## This TransitionCamera will always be the active camera. 
## Its purpose is to move and change zoom based on other Camera2ds and their properties
class_name TransitionCamera
extends Camera2D


@export var main_scene_camera: Camera2D


@onready var _source_rect := Util.get_camera_viewport(self).get_visible_rect()
@onready var _dest_rect := _source_rect
var _transition_time: float = 1.0
var _cur_transition_time: float = 1.0
var _is_transitioning: bool = false
var _is_showing_main_scene: bool = true
var _is_grabbing_mouse: bool = false


func _ready() -> void:
	make_current()

func _process(delta: float) -> void:
	if _is_transitioning:
		_cur_transition_time += delta
		var t: float = clamp(_cur_transition_time / _transition_time, 0.0, 1.0)
		t = ease(t, 0.3)

		var cur_rect := Util.get_camera_world_rect(self)
		var next_rect := Util.lerp_rect2(_source_rect, _dest_rect, t)

		# Keep the mouse in the same spot relative to the screen.
		if _is_grabbing_mouse:
			var mouse_frac: Vector2 = (Cursor.virtual_mouse_position - cur_rect.position) / cur_rect.size
			Cursor.virtual_mouse_position = next_rect.position + mouse_frac * next_rect.size

		Util.set_camera_world_rect(self, next_rect)

		if _cur_transition_time >= _transition_time:
			_is_transitioning = false

func _input(event: InputEvent) -> void:
	# Unzoom camera
	if event.is_action_pressed("ExitCameraZoom") and not is_showing_main_scene():
		return_to_main_scene()

## Transition the camera to frame [param rect]. If [param grab_mouse] is [code]true[/code], then
## the virtual cursor will be moved along with the camera.
func move_to_rect(rect: Rect2, grab_mouse: bool = true, time: float = 0.7) -> void:
	_dest_rect = rect
	_source_rect = Util.get_camera_world_rect(self)
	_transition_time = time
	_cur_transition_time = 0.0
	_is_transitioning = true
	_is_showing_main_scene = false
	_is_grabbing_mouse = grab_mouse

func move_to_camera(camera: Camera2D, grab_mouse: bool = true, time: float = 0.7) -> void:
	move_to_rect(Util.get_camera_world_rect(camera), grab_mouse, time)

func return_to_main_scene(time: float = 0.7) -> void:
	move_to_camera(main_scene_camera, false, time)
	_is_showing_main_scene = true

func is_showing_main_scene() -> bool:
	return _is_showing_main_scene and not _is_transitioning
