## Keeps track of interaction-related state, ensuring that only one interaction can happen at once.
extends Node2D


class InteractState:
	var info: InteractInfo

	# The use component doing the acting. This will be null if the target is acting by itself just
	# with the held object.
	var source: UseComponent

	# This can point to an `InteractableArea` or a `SelectableComponent`. Both of them have
	# hovering and interacting behavior, but there's no way in Godot to have an interface that they
	# can both implement, so the type just has to be switched on.
	var target: Node2D
	var is_pressed: bool = false


	func _init(p_info: InteractInfo = null, p_source: UseComponent = null, p_target: Node2D = null) -> void:
		info = p_info
		source = p_source
		target = p_target


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

## Current potential interactions by kind.
var interactions: Dictionary[InteractInfo.Kind, InteractState] = {
	InteractInfo.Kind.PRIMARY: InteractState.new(),
	InteractInfo.Kind.SECONDARY: InteractState.new(),
}


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
	var new_interactions: Dictionary[InteractInfo.Kind, InteractState] = {}

	if active_drag_component:
		# As a special case, the active drag component is allowed to be interacted with by itself
		# so it can be dropped. This is here first so that it has the lowest priority.
		#
		# TODO: somehow make this less of a special case?
		var drag_interact_state := InteractState.new()
		drag_interact_state.info = InteractInfo.new(InteractInfo.Kind.PRIMARY, "Put down")
		drag_interact_state.target = active_drag_component
		new_interactions.set(InteractInfo.Kind.PRIMARY, drag_interact_state)

		for a in _interact_area_stack:
			for info in a.get_interactions():
				var s := InteractState.new()
				s.info = info
				s.target = a
				new_interactions.set(info.kind, s)

		# `UseComponent`s take priority over `InteractableArea`s.
		for c: UseComponent in active_drag_component.body.find_children("", "UseComponent", false):
			if not _interact_area_stack:
				for info in c.get_interactions(null):
					new_interactions.set(info.kind, InteractState.new(info, c, null))

			for a in _interact_area_stack:
				for info in c.get_interactions(a):
					new_interactions.set(info.kind, InteractState.new(info, c, a))
	else:
		hovered_selectable_component = null
		_hovered_z_index = RenderingServer.CANVAS_ITEM_Z_MIN

		# Find the topmost thing that can be clicked on.
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

		if hovered_selectable_component:
			var s := InteractState.new()
			# TODO: the `SelectableComponent` itself should decide what the interaction is called.
			s.info = InteractInfo.new(InteractInfo.Kind.PRIMARY, "Pick up")
			s.target = hovered_selectable_component
			new_interactions.set(InteractInfo.Kind.PRIMARY, s)

	for kind: InteractInfo.Kind in interactions.keys():
		var state: InteractState = interactions[kind]
		var new_state: InteractState = new_interactions.get(kind)

		# Never retarget an interaction while it's being pressed (this would introduce bizarre
		# behavior where you could click and drag something and it would show a button prompt
		# for something unrelated when the mouse moves to the wrong spot.
		if not state or state.is_pressed: continue

		# Interaction was retargeted.
		if state.target and (not new_state or new_state.target != state.target):
			_stop_targeting(state.target, state.info.kind)

		if new_state:
			if new_state.target != state.target:
				_start_targeting(new_state.target, new_state.info.kind)
			state.info = new_state.info
			state.target = new_state.target
		else:
			state.info = null
			state.target = null

	if held_selectable_component or active_drag_component:
		hovered_selectable_component = null

func _unhandled_input(e: InputEvent) -> void:
	var kind := InteractInfo.Kind.PRIMARY
	if e.is_action(&"interact_primary"):
		kind = InteractInfo.Kind.PRIMARY
	elif e.is_action(&"interact_secondary"):
		kind = InteractInfo.Kind.SECONDARY
	else:
		return

	var state: InteractState = interactions.get(kind)
	if not state: return

	if state.target:
		if e.is_pressed():
			state.is_pressed = true
			_start_interact(state.target, kind)
		elif e.is_released():
			state.is_pressed = false
			_stop_interact(state.target, kind)

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
	for state: InteractState in interactions.values():
		if state.target: _stop_targeting(state.target, state.info.kind)

func _start_targeting(target: Node2D, kind: InteractInfo.Kind) -> void:
	if target is InteractableArea: target.start_targeting(kind)
	elif target is SelectableComponent: target.start_targeting()
func _stop_targeting(target: Node2D, kind: InteractInfo.Kind) -> void:
	if target is InteractableArea: target.stop_targeting(kind)
	elif target is SelectableComponent: target.stop_targeting()
func _start_interact(target: Node2D, kind: InteractInfo.Kind) -> void:
	if target is InteractableArea: target.start_interact(kind)
	elif target is SelectableComponent: target.start_interact()
func _stop_interact(target: Node2D, kind: InteractInfo.Kind) -> void:
	if target is InteractableArea: target.stop_interact(kind)
	elif target is SelectableComponent: target.stop_interact()

# Don't know if this is 100% correct, but it works for now. Get the "absolute" z-index of a node,
# taking into account relative z indices.
static func _get_absolute_z_index(n: Node) -> int:
	if not (n is CanvasItem):
		return 0
	elif n.z_as_relative:
		return _get_absolute_z_index(n.get_parent()) + n.z_index
	else:
		return n.z_index
