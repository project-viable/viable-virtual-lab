class_name ZoomAwareControl
extends Control
## A [Control] node that allows its descendants to be interacted with by the mouse only if the
## screen is zoomed in.


var _original_mouse_filters: Dictionary[Control, Control.MouseFilter] = {}


func _enter_tree() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func _ready() -> void:
	_save_descendant_mouse_filters()
	Game.main.camera_focus_owner_changed.connect(_on_main_camera_focus_owner_changed)
	_on_main_camera_focus_owner_changed(null)

func _on_main_camera_focus_owner_changed(focus_owner: Node) -> void:
	# Zoomed out.
	if focus_owner == null:
		for c: Control in _original_mouse_filters.keys():
			c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	# Zoomed in.
	else:
		_restore_descendant_mouse_filters()

func _save_descendant_mouse_filters() -> void:
	for c: Control in find_children("", "Control"):
		_original_mouse_filters.set(c, c.mouse_filter)

func _restore_descendant_mouse_filters() -> void:
	for c: Control in _original_mouse_filters.keys():
		c.mouse_filter = _original_mouse_filters[c]
