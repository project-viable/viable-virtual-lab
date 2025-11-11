@tool
class_name SubsceneCamera
extends Camera2D
## Provides a view of part of a subscene.
##
## Since this is shown in a box in  the middle of the
## screen rather than filling the whole viewport, it can't just be enabled using
## [method Camera2D.make_current]; instead, it must be enabled with the [Subscenes] singleton.
##
## Unlike normal cameras, which determine their size based on their viewport, a [SubsceneCamera]
## actually dictates the size of the viewport. This means that you can't set the scale directly;
## instead, you should set the [member display_size] variable.


## Size of the region displayed by this camera, in local coordinates. The region will always be
## centered on the position of this camera.
@export var region_size: Vector2 = Vector2(100, 100) :
	set(v):
		region_size = v
		if Engine.is_editor_hint(): queue_redraw()


var _last_offset := offset


func _enter_tree() -> void:
	# The default (main) viewport is not the one that will be used by this camera, so the display
	# bounds shown will be incorrect. This means we have to disable the default bounds rectangle
	# and draw our own.
	editor_draw_screen = false
	# The engine uses the wrong viewport's size, which causes the position to be incorrect when
	# using the centered anchor position, so we have to use top left.
	anchor_mode = Camera2D.ANCHOR_MODE_FIXED_TOP_LEFT

func _draw() -> void:
	if Engine.is_editor_hint():
		draw_rect(Rect2(Vector2.ZERO, region_size), Color.RED, false)

		if _last_offset != offset:
			queue_redraw()
			_last_offset = offset
