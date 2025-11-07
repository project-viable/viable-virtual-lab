class_name SubscenePopup
extends Node2D
## Makes it possible to display a [SubsceneCamera].


## The preferred side of the parent object that the popup should appear on. If it does not fit on
## the screen on that side, then it will be put on a different side.
@export var side_hint: Side = SIDE_TOP
@export var popup_margin: float = 30.0
@export var subscene_camera: SubsceneCamera


func _ready() -> void:
	$CanvasLayer.custom_viewport = Subscenes.top_level_viewport
	$%SubViewport.world_2d = Subscenes.main_world_2d
	hide()
	$%SubViewportContainer.hide()

func start_displaying() -> void:
	if not subscene_camera: return
	subscene_camera.custom_viewport = $%SubViewport
	$%SubViewportContainer.size = subscene_camera.region_size
	subscene_camera.make_current()

	# Get the position of this node with respect to the subscene canvas layer.
	var screen_pos: Vector2 = $CanvasLayer.get_final_transform().affine_inverse() \
			* get_global_transform_with_canvas().get_origin()
	var offset := -subscene_camera.region_size / 2.0

	match side_hint:
		SIDE_TOP: offset.y = -subscene_camera.region_size.y - popup_margin
		SIDE_BOTTOM: offset.y = popup_margin
		SIDE_LEFT: offset.x = popup_margin
		SIDE_RIGHT: offset.x = -subscene_camera.region_size.x - popup_margin

	$%SubViewportContainer.global_position = screen_pos + offset
	show()
	$%SubViewportContainer.show()

func stop_displaying() -> void:
	hide()
	$%SubViewportContainer.hide()
