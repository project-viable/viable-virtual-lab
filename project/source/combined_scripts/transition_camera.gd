extends Camera2D
## This TransitionCamera will always be the active camera. 
## Its purpose is to move and change zoom based on other Camera2ds and their properties

@export var main_scene_camera: Camera2D
var current_camera: Camera2D
func _ready() -> void:
	make_current() 

func _process(_delta: float) -> void:
	if GameState.target_camera and current_camera != GameState.target_camera:
		change_camera(GameState.target_camera)
		GameState.is_camera_zoomed = true
	
func _input(event: InputEvent) -> void:
	# Unzoom camera
	if event.is_action_pressed("ExitCameraZoom") and current_camera != main_scene_camera:
		GameState.target_camera = main_scene_camera
		change_camera(main_scene_camera)
		
## Transition the TransitionCamera and its properties to the target camera
func change_camera(target_camera: Camera2D) -> void:
	current_camera = target_camera
	var position_tween: Tween = create_tween()
	var zoom_tween: Tween = create_tween()
	
	position_tween.tween_property(self, "position", target_camera.global_position, 1)
	zoom_tween.tween_property(self, "zoom", target_camera.zoom, 1).set_ease(Tween.EASE_IN_OUT)
	await position_tween.finished

	# Prevents opening of menu via escape until the tweens are finished
	if target_camera == main_scene_camera:
		GameState.is_camera_zoomed = false
