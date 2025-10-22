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


func _ready() -> void:
	make_current()

func _process(delta: float) -> void:
	if _is_transitioning:
		_cur_transition_time += delta
		var t: float = clamp(_cur_transition_time / _transition_time, 0.0, 1.0)

		var cur_rect := Util.lerp_rect2(_source_rect, _dest_rect, t)
		Util.set_camera_world_rect(self, cur_rect)

		if _cur_transition_time >= _transition_time:
			_is_transitioning = false

func _input(event: InputEvent) -> void:
	# Unzoom camera
	if event.is_action_pressed("ExitCameraZoom") and not is_showing_main_scene():
		return_to_main_scene()

## Transition the camera to frame [param rect]
func move_to_rect(rect: Rect2, time: float = 0.5) -> void:
	_dest_rect = rect
	_source_rect = Util.get_camera_world_rect(self)
	_transition_time = time
	_cur_transition_time = 0.0
	_is_transitioning = true
	_is_showing_main_scene = false

func move_to_camera(camera: Camera2D, time: float = 0.5) -> void:
	move_to_rect(Util.get_camera_world_rect(camera), time)

func return_to_main_scene() -> void:
	move_to_camera(main_scene_camera)
	_is_showing_main_scene = true

func is_showing_main_scene() -> bool:
	return _is_showing_main_scene and not _is_transitioning
