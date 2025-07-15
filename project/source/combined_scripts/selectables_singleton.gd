## Used to help `SelectableCanvasGroup`s keep track of their draw order. In
## its `_draw` function, a `SelectableCanvasGroup` calls `get_next_index` to get
## its "index". I.e., the order that it was drawn.
class_name SelectableSingleton
extends Node2D


## Set to the "best" `SelectableComponent` currently being highlighted, so that the components
## themselves can know if they are the correct choice.
var hovered_component: SelectableComponent = null


# The "draw index" of the next `SelectableCanvasGroup` to call `_draw`. The
# idea that the order they call `_draw` would correspond with the which one is on top (if `_draw`
# is called later, then it is on top).
var _next_index: int = 0
var _hovered_z_index: int = RenderingServer.CANVAS_ITEM_Z_MIN
var _hovered_draw_order: int = 0


func _draw() -> void:
	_next_index = 0

func _process(_delta: float) -> void:
	hovered_component = null
	_hovered_z_index = RenderingServer.CANVAS_ITEM_Z_MIN

	# Find the topmost 
	for c in get_tree().get_nodes_in_group(&"selectable_component"):
		if c is SelectableComponent:
			var z := _get_absolute_z_index(c.interact_canvas_group)
			var draw_order: int = c.interact_canvas_group.draw_order_this_frame

			if c.interact_canvas_group.is_mouse_hovering() \
					and (not hovered_component
						or z > _hovered_z_index
						or draw_order > _hovered_draw_order and not z < _hovered_z_index):
				hovered_component = c
				_hovered_z_index = z
				_hovered_draw_order = draw_order

func get_next_index() -> int:
	_next_index += 1
	return _next_index - 1

# Don't know if this is 100% correct, but it works for now. Get the "absolute" z-index of a node,
# taking into account relative z indices.
static func _get_absolute_z_index(n: Node) -> int:
	if not (n is CanvasItem):
		return 0
	elif n.z_as_relative:
		return _get_absolute_z_index(n.get_parent()) + n.z_index
	else:
		return n.z_index
