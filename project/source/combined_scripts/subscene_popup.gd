class_name SubscenePopup
extends Node2D
## Makes it possible to display a [SubsceneCamera].


## The preferred side of the parent object that the popup should appear on. If it does not fit on
## the screen on that side, then it will be put on a different side.
@export var side_hint: Side = SIDE_TOP
@export var popup_margin: float = 30.0


func _ready() -> void:
	$CanvasLayer.custom_viewport = Subscenes.top_level_viewport
	$%SubViewport.world_2d = Subscenes.main_world_2d

func start_displaying(camera: SubsceneCamera) -> void:
	if not camera: return
	camera.custom_viewport = $%SubViewport
	$%SubViewportContainer.size = camera.region_size
	camera.make_current()

	# Get the position of this node with respect to the subscene canvas layer.
	var screen_pos: Vector2 = $CanvasLayer.get_final_transform().affine_inverse() \
			* get_global_transform_with_canvas().get_origin()
	var offset := -camera.region_size / 2.0

	match side_hint:
		SIDE_TOP: offset.y = -camera.region_size.y - popup_margin
		SIDE_BOTTOM: offset.y = popup_margin
		SIDE_LEFT: offset.x = popup_margin
		SIDE_RIGHT: offset.x = -camera.region_size.x - popup_margin

	$%SubViewportContainer.global_position = screen_pos + offset

	show()

func stop_displaying() -> void:
	hide()
