class_name ZoomSelectableArea
extends SelectableAreaComponent
## Allows the user to press the inspect button when hovering to zoom in on a set of objects.
##
## Note: If [member interact_info] does not use [const InteractInfo.Kind.INSPECT], then it will be
## replaced with a generic zoom interact info.


signal zoomed_in()
signal zoomed_out()


## If not set to null, this camera's rectangle will be fully included in the zoomed area.
@export var area_camera: Camera2D

## These objects will [i]always[/i] be in frame.
@export var objects: Array[CollisionObject2D] = []

## Any nearby object in one of these groups will be included in the frame, as long as it wouldn't
## extend any edge of the frame more than [member search_radius] past the position of this node.
@export var search_groups: Array[StringName] = []
@export var search_radius: float = 200

## If set, zooming in will also display the contents of this subscene camera.
@export var subscene_camera: SubsceneCamera


var _is_zoomed_in := false


func _ready() -> void:
	super()
	if interact_info.kind != InteractInfo.Kind.INSPECT:
		interact_info = InteractInfo.new(InteractInfo.Kind.INSPECT, "Zoom in")
	Game.main.camera_focus_owner_changed.connect(_on_main_camera_focus_owner_changed)


func _press() -> void:
	var has_rect := false
	var zoom_rect := Rect2()

	if area_camera:
		zoom_rect = Util.get_camera_world_rect(area_camera)
		has_rect = true

	for o in objects:
		var rect := Util.get_global_bounding_box(o)
		if has_rect:
			zoom_rect = zoom_rect.merge(rect)
		else:
			zoom_rect = rect
			has_rect = true

	var search_rect := Rect2(global_position - search_radius * Vector2.ONE, 2 * search_radius * Vector2.ONE)
	for g in search_groups:
		for o in get_tree().get_nodes_in_group(g):
			if o is CollisionObject2D:
				var rect := Util.get_global_bounding_box(o)
				if not search_rect.encloses(rect): continue

				if has_rect:
					zoom_rect = zoom_rect.merge(rect)
				else:
					zoom_rect = rect
					has_rect = true

	# Simply don't do anything if nothing was found.
	if not has_rect: return

	if subscene_camera:
		Game.main.focus_camera_and_show_subscene(zoom_rect, subscene_camera)
	else:
		Game.main.focus_camera_on_rect(zoom_rect)
	Game.main.set_camera_focus_owner(self)
	_is_zoomed_in = true
	enable_interaction = false
	zoomed_in.emit()

func _on_main_camera_focus_owner_changed(focus_owner: Node) -> void:
	if _is_zoomed_in and focus_owner != self:
		_is_zoomed_in = false
		zoomed_out.emit()
		enable_interaction = true
