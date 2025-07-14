## Used to help `SelectableCanvasGroup`s keep track of their draw order. In
## its `_draw` function, a `SelectableCanvasGroup` calls `get_next_index` to get
## its "index". I.e., the order that it was drawn.
class_name SelectableSingleton
extends Node2D


## Set to the "best" `DragComponent` currently being highlighted, so that the
## components themselves can know if they are the correct choice.
var hovered_drag_component: DragComponent = null


# The "draw index" of the next `SelectableCanvasGroup` to call `_draw`. The
# idea that the order they call `_draw` would correspond with the which one is on top (if `_draw`
# is called later, then it is on top).
var _next_index: int = 0


func _draw() -> void:
	_next_index = 0

func _process(_delta: float) -> void:
	hovered_drag_component = null
	for c in get_tree().get_nodes_in_group(&"drag_component"):
		if c is DragComponent \
				and c.interact_canvas_group.is_mouse_hovering() \
				and (not hovered_drag_component
					or c.interact_canvas_group.draw_order_this_frame > hovered_drag_component.interact_canvas_group.draw_order_this_frame):
			hovered_drag_component = c

func get_next_index() -> int:
	_next_index += 1
	return _next_index - 1
