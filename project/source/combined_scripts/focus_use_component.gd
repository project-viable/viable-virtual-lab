class_name FocusUseComponent
extends UseComponent
## Allows the user to press the focus key while holding an object to zoom in on it.


## The object to zoom in on. If not set, this will be seet to this node's parent,
## if it is the correct type.
@export var focus_object: CollisionObject2D

@export var left_padding: float = 0
@export var top_padding: float = 0
@export var right_padding: float = 0
@export var bottom_padding: float = 0


var _is_zoomed := false
var _orig_cursor_pos := Vector2.ZERO


func _ready() -> void:
	if not focus_object and get_parent() is CollisionObject2D:
		focus_object = get_parent()
	Game.main.camera_focus_owner_changed.connect(_on_main_camera_focus_owner_changed)

func get_interactions(_a: InteractableArea) -> Array[InteractInfo]:
	if not _is_zoomed and focus_object:
		return [InteractInfo.new(InteractInfo.Kind.INSPECT, "Focus")]
	else:
		return []

func start_use(_a: InteractableArea, _k: InteractInfo.Kind) -> void:
	if not _is_zoomed:
		_is_zoomed = true
		var rect := Util.get_global_bounding_box(focus_object) \
				.grow_individual(left_padding, top_padding, right_padding, bottom_padding)
		Game.main.focus_camera_on_rect(rect)
		Game.main.set_camera_focus_owner(self)
		_orig_cursor_pos = Cursor.virtual_mouse_position

		if focus_object is LabBody:
			focus_object.disable_drop = true
			focus_object.disable_follow_cursor = true

func _on_main_camera_focus_owner_changed(focus_owner: Node) -> void:
	if _is_zoomed and focus_owner != self:
		_is_zoomed = false
		focus_object.disable_drop = false
		focus_object.disable_follow_cursor = false
		Cursor.virtual_mouse_position = _orig_cursor_pos
