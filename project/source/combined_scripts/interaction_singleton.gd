## Keeps track of interaction-related state, ensuring that only one interaction can happen at once.
extends Node2D


## Set to the "best" `SelectableComponent` currently being highlighted, so that the components
## themselves can know if they are the correct choice. This will always be null if the user
## currently has a selectable component held down or is dragging a drag component.
var hovered_selectable_component: SelectableComponent = null

## If any, set to the `SelectableComponent` that is currently held (i.e., its press mode is `HOLD`,
## it was clicked, and it has not been released yet). This is set directly by
## `SelectableComponent`.
var held_selectable_component: SelectableComponent = null

## Set to the `DragComponent` currently being dragged, if it exists. This is set directly by
## `DragComponent`.
var active_drag_component: DragComponent = null

## Set to the `InteractableArea` that is currently the (potential) target to be interacted with by
## the dragged object.
var target_interact_area: InteractableArea = null


# The "draw order" of the next `SelectableCanvasGroup` to call `_draw`. The
# idea that the order they call `_draw` would correspond with the which one is on top (if `_draw`
# is called later, then it is on top).
var _next_draw_order: int = 0
var _hovered_z_index: int = RenderingServer.CANVAS_ITEM_Z_MIN
var _hovered_draw_order: int = 0
var _interact_area_stack: Array[InteractableArea] = []


func _draw() -> void:
	_next_draw_order = 0

func _process(_delta: float) -> void:
	hovered_selectable_component = null
	_hovered_z_index = RenderingServer.CANVAS_ITEM_Z_MIN

	# Find the topmost 
	for c in get_tree().get_nodes_in_group(&"selectable_component"):
		if c is SelectableComponent:
			var z := _get_absolute_z_index(c.interact_canvas_group)
			var draw_order: int = c.interact_canvas_group.draw_order_this_frame

			if c.interact_canvas_group.is_mouse_hovering() \
					and (not hovered_selectable_component
						or z > _hovered_z_index
						or draw_order > _hovered_draw_order and not z < _hovered_z_index):
				hovered_selectable_component = c
				_hovered_z_index = z
				_hovered_draw_order = draw_order

	if held_selectable_component or active_drag_component:
		hovered_selectable_component = null

func get_next_draw_order() -> int:
	_next_draw_order += 1
	return _next_draw_order - 1

# When a body `b` enters an `InteractableArea` and `active_drag_component.body` is equal to `b`, that
# interaction area should call this function, passing itself as the argument.
func on_interaction_area_entered(area: InteractableArea) -> void:
	_interact_area_stack.append(area)

func on_interaction_area_exited(area: InteractableArea) -> void:
	_interact_area_stack.erase(area)

# Delete any hovered interactions. This is called by `DragComponent` when it's dropped.
func clear_interaction_stack() -> void:
	_interact_area_stack.clear()

# Don't know if this is 100% correct, but it works for now. Get the "absolute" z-index of a node,
# taking into account relative z indices.
static func _get_absolute_z_index(n: Node) -> int:
	if not (n is CanvasItem):
		return 0
	elif n.z_as_relative:
		return _get_absolute_z_index(n.get_parent()) + n.z_index
	else:
		return n.z_index
