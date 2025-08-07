## Keeps track of interaction-related state, ensuring that only one interaction can happen at once.
extends Node2D


class InteractState:
	var info: InteractInfo

	# The use component doing the acting. This will be null if the target is acting by itself just
	# with the held object.
	var source: UseComponent

	# This can point to an `InteractableArea` or an `InteractableComponent`. Both of them have
	# hovering and interacting behavior, but there's no way in Godot to have an interface that
	# they can both implement, so the type just has to be switched on.
	var target: Node2D
	var is_pressed: bool = false


	func _init(p_info: InteractInfo = null, p_source: UseComponent = null, p_target: Node2D = null) -> void:
		info = p_info
		source = p_source
		target = p_target

	func start_targeting() -> void:
		if not info: return
		if source: source.start_targeting(target as InteractableArea, info.kind)
		elif target is InteractableArea: target.start_targeting(info.kind)
		elif target is InteractableComponent: target.start_targeting(info.kind)

	func stop_targeting() -> void:
		if not info: return
		if source: source.stop_targeting(target as InteractableArea, info.kind)
		elif target is InteractableArea: target.stop_targeting(info.kind)
		elif target is InteractableComponent: target.stop_targeting(info.kind)

	func start_interact() -> void:
		is_pressed = true
		if not info: return
		if source: source.start_use(target as InteractableArea, info.kind)
		elif target is InteractableArea: target.start_interact(info.kind)
		elif target is InteractableComponent: target.start_interact(info.kind)

	func stop_interact() -> void:
		is_pressed = false
		if not info: return
		if source: source.stop_use(target as InteractableArea, info.kind)
		elif target is InteractableArea: target.stop_interact(info.kind)
		elif target is InteractableComponent: target.stop_interact(info.kind)


## Set to the `DragComponent` currently being dragged, if it exists. This is set directly by
## `DragComponent`.
var active_drag_component: DragComponent = null

## Current `InteractableComponent`, if any, being hovered.
var hovered_interactable_component: InteractableComponent = null

## Current potential interactions by kind.
var interactions: Dictionary[InteractInfo.Kind, InteractState] = {
	InteractInfo.Kind.PRIMARY: InteractState.new(),
	InteractInfo.Kind.SECONDARY: InteractState.new(),
}


# The "draw order" of the next `SelectableCanvasGroup` to call `_draw`. The
# idea that the order they call `_draw` would correspond with the which one is on top (if `_draw`
# is called later, then it is on top).
var _next_draw_order: int = 0
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
		for info in active_drag_component.get_interactions():
			new_interactions.set(info.kind, InteractState.new(info, null, active_drag_component))

		for a in _interact_area_stack:
			if not a.enable_interaction: continue
			for info in a.get_interactions():
				new_interactions.set(info.kind, InteractState.new(info, null, a))

		# `UseComponent`s take priority over `InteractableArea`s.
		for c: UseComponent in active_drag_component.body.find_children("", "UseComponent", false):
			#if not c.enable_interaction: continue

			if not _interact_area_stack:
				for info in c.get_interactions(null):
					new_interactions.set(info.kind, InteractState.new(info, c, null))

			for a in _interact_area_stack:
				for info in c.get_interactions(a):
					new_interactions.set(info.kind, InteractState.new(info, c, a))
	else:
		hovered_interactable_component = null
		var hovered_z_index := RenderingServer.CANVAS_ITEM_Z_MIN
		var hovered_draw_order := 0

		# Find the topmost thing that can be clicked on.
		for c in get_tree().get_nodes_in_group(&"interactable_component"):
			if c is InteractableComponent and c.enable_interaction:
				var z: int = c.get_absolute_z_index()
				var draw_order: int = c.get_draw_order()

				if c.is_hovered() \
						and (not hovered_interactable_component
							or z > hovered_z_index
							or draw_order > hovered_draw_order and not z < hovered_z_index):
					hovered_interactable_component = c
					hovered_z_index = z
					hovered_draw_order = draw_order

		if hovered_interactable_component:
			for info in hovered_interactable_component.get_interactions():
				var s := InteractState.new(info, null, hovered_interactable_component)
				new_interactions.set(info.kind, s)

	for kind: InteractInfo.Kind in interactions.keys():
		var state: InteractState = interactions[kind]
		var new_state: InteractState = new_interactions.get(kind)

		# Never retarget an interaction while it's being pressed (this would introduce bizarre
		# behavior where you could click and drag something and it would show a button prompt
		# for something unrelated when the mouse moves to the wrong spot.
		if not state or state.is_pressed: continue

		# Interaction was retargeted.
		if state.target and (not new_state or new_state.target != state.target):
			state.stop_targeting()

		if new_state:
			if new_state.target != state.target or new_state.source != state.source:
				new_state.start_targeting()
			state.info = new_state.info
			state.source = new_state.source
			state.target = new_state.target
		else:
			state.info = null
			state.target = null

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

	if e.is_pressed(): state.start_interact()
	elif e.is_released(): state.stop_interact()

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
		if state.target: state.stop_targeting()
