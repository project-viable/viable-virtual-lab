class_name ContentScaledSubViewportContainer
extends TextureRect
## Acts like a stripped-down version of [SubViewportContainer], but respects
## [constant Window.CONTENT_SCALE_MODE_CANVAS_ITEMS]
##
## Normally, [SubViewportContainer] displays the content of a [SubViewport] at exactly that
## viewport's size. However, sometimes, we want to render at a higher resolution and scale down.
## This handles that.


@onready var _viewport: SubViewport = Util.find_child_of_type(self, SubViewport)


func _ready() -> void:
	expand_mode = EXPAND_IGNORE_SIZE
	texture = _viewport.get_texture()
	_viewport.handle_input_locally = false

func _notification(what: int) -> void:
	# The viewport needs to know when the mouse enters and leaves, since it won't do physics object
	# picking otherwise.
	match what:
		NOTIFICATION_MOUSE_ENTER: _viewport.notification(NOTIFICATION_VP_MOUSE_ENTER)
		NOTIFICATION_MOUSE_EXIT: _viewport.notification(NOTIFICATION_VP_MOUSE_EXIT)

func _input(e: InputEvent) -> void:
	_propagate_nonpositional_event(e)

func _unhandled_input(e: InputEvent) -> void:
	_propagate_nonpositional_event(e)

func _gui_input(e: InputEvent) -> void:
	if _is_propagated_in_gui_input(e):
		_send_event_to_viewport(e.xformed_by(Transform2D.IDENTITY.scaled((_viewport.size as Vector2) / size)))

func _propagate_nonpositional_event(e: InputEvent) -> void:
	if not _is_propagated_in_gui_input(e):
		_send_event_to_viewport(e)

func _is_propagated_in_gui_input(e: InputEvent) -> bool:
	return e is InputEventMouse or e is InputEventScreenDrag or e is InputEventScreenTouch or e is InputEventGesture

func _send_event_to_viewport(e: InputEvent) -> void:
	if _viewport and not _viewport.is_input_disabled():
		_viewport.push_input(e)
