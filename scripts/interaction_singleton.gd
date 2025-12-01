## Keeps track of interaction-related state, ensuring that only one interaction can happen at once.
## The actual input handling (translating input events into interactions) is done in the
## [code]$%Scene[/code] node in the main scene.
extends Node2D


class InteractState:
	var info: InteractInfo

	# The use component doing the acting. This will be null if the target is acting by itself just
	# with the held object.
	var source: UseComponent

	# This can point to an `InteractableArea` or an `InteractableComponent`. Both of them have
	# hovering and interacting behavior, but there's no way in Godot to have an interface that
	# they can both implement, so the type just has to be switched on.
	#
	# It can also be the currently held `LabBody`.
	var target: Node2D
	var is_pressed: bool = false


	func _init(p_info: InteractInfo = null, p_source: UseComponent = null, p_target: Node2D = null) -> void:
		info = p_info
		source = p_source
		target = p_target

	func start_targeting() -> void:
		if not info: return
		if source: source.start_targeting(target as InteractableArea, info.kind)
		if target is InteractableArea or target is InteractableComponent or target is LabBody or target is InteractableSystem:
			target.start_targeting(info.kind)

	func stop_targeting() -> void:
		if not info: return
		if source: source.stop_targeting(target as InteractableArea, info.kind)
		if target is InteractableArea or target is InteractableComponent or target is LabBody or target is InteractableSystem:
			target.stop_targeting(info.kind)

	func start_interact() -> void:
		is_pressed = true
		if not info or not info.allowed: return
		if source: source.start_use(target as InteractableArea, info.kind)
		if target is InteractableArea or target is InteractableComponent or target is LabBody or target is InteractableSystem:
			target.start_interact(info.kind)

	func stop_interact() -> void:
		is_pressed = false
		if not info or not info.allowed: return
		if source: source.stop_use(target as InteractableArea, info.kind)
		if target is InteractableArea or target is InteractableComponent or target is LabBody or target is InteractableSystem:
			target.stop_interact(info.kind)


## `LabBody` currently being held.
var held_body: LabBody = null

## Current potential interactions by kind.
var interactions: Dictionary[InteractInfo.Kind, InteractState] = {}


# The "draw order" of the next `SelectableCanvasGroup` to call `_draw`. The
# idea that the order they call `_draw` would correspond with the which one is on top (if `_draw`
# is called later, then it is on top).
var _next_draw_order: int = 0
var _interact_area_stack: Array[InteractableArea] = []


func _ready() -> void:
	# Interaction only works when in the simulation.
	process_mode = Node.PROCESS_MODE_PAUSABLE

	for kind: InteractInfo.Kind in InteractInfo.Kind.values():
		interactions[kind] = InteractState.new()

func _draw() -> void:
	_next_draw_order = 0

func _process(_delta: float) -> void:
	var new_interactions: Dictionary[InteractInfo.Kind, InteractState] = {}

	for c in get_tree().get_nodes_in_group(&"interactable_system"):
		if c is InteractableSystem and c.enable_interaction:
			for info: InteractInfo in c.get_interactions():
				new_interactions.set(info.kind, InteractState.new(info, null, c))

	if held_body:
		# The currently held `LabBody` can also be interacted with (mostly to put it down),
		var drop_info := InteractInfo.new(InteractInfo.Kind.PRIMARY, "Put down")
		for info in held_body.get_interactions():
			new_interactions.set(info.kind, InteractState.new(info, null, held_body))

		for a in _interact_area_stack:
			if not a.enable_interaction: continue
			for info in a.get_interactions():
				new_interactions.set(info.kind, InteractState.new(info, null, a))

		# `UseComponent`s take priority over `InteractableArea`s.
		for c: UseComponent in held_body.find_children("", "UseComponent", false):
			#if not c.enable_interaction: continue

			if not _interact_area_stack:
				for info in c.get_interactions(null):
					new_interactions.set(info.kind, InteractState.new(info, c, null))

			for a in _interact_area_stack:
				for info in c.get_interactions(a):
					new_interactions.set(info.kind, InteractState.new(info, c, a))
	else:
		# Find the topmost thing that can be clicked on.
		for c in get_tree().get_nodes_in_group(&"interactable_component"):
			if not (c is InteractableComponent or c is LabBody) or not c.enable_interaction:
				continue

			for info: InteractInfo in c.get_interactions():
				var prev_state: InteractState = new_interactions.get(info.kind)
				var prev_component: Node2D = prev_state.target if prev_state else null

				if _interactable_component_is_preferred(prev_component, c):
					var s := InteractState.new(info, null, c)
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

func get_next_draw_order() -> int:
	_next_draw_order += 1
	return _next_draw_order - 1

# When a body `b` enters an `InteractableArea` and `held_body` is equal to `b`, that interaction
# area should call this function, passing itself as the argument.
func on_interaction_area_entered(area: InteractableArea) -> void:
	_interact_area_stack.append(area)

func on_interaction_area_exited(area: InteractableArea) -> void:
	_interact_area_stack.erase(area)

# Delete any hovered interactions. This is called by `DragComponent` when it's dropped.
func clear_interaction_stack() -> void:
	_interact_area_stack.clear()
	for state: InteractState in interactions.values():
		if state.target: state.stop_targeting()

# Return true if [param b] should be chosen as an interactable component to use, given that
# [param a] was the previous best choice. This will [i]only[/i] return [code]true[/code] if
# [param b] is a valid choice (i.e., it's of the correct type and is hovered).
static func _interactable_component_is_preferred(a: Node2D, b: Node2D) -> bool:
	var a_is_valid: bool = (a is InteractableComponent or a is LabBody)
	var b_is_valid: bool = (b is InteractableComponent or b is LabBody) and b.enable_interaction and b.is_hovered()

	if not b_is_valid: return false
	if not a_is_valid: return true

	var a_z: int = a.get_absolute_z_index()
	var a_draw_order: int = a.get_draw_order()
	var b_z: int = b.get_absolute_z_index()
	var b_draw_order: int = b.get_draw_order()

	return b_z > a_z or (b_z == a_z and b_draw_order > a_draw_order)
