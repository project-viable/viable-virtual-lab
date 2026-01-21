## Keeps track of interaction-related state, ensuring that only one interaction can happen at once.
## The actual input handling (translating input events into interactions) is done in the
## [code]$%Scene[/code] node in the main scene.
extends Node2D


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
				new_interactions.set(info.kind, SystemInteractState.new(info, c))

	if held_body:
		for info in held_body.get_interactions():
			new_interactions.set(info.kind, UseInteractState.new(info, held_body, null))

		for a in _interact_area_stack:
			if not a.enable_interaction: continue
			for info in a.get_interactions():
				new_interactions.set(info.kind, UseInteractState.new(info, null, a))

		# `UseComponent`s take priority over `InteractableArea`s.
		for c: UseComponent in held_body.find_children("", "UseComponent", false):
			if not c.enable_interaction: continue

			for a in _interact_area_stack:
				for info in c.get_interactions(a):
					new_interactions.set(info.kind, UseInteractState.new(info, c, a))

			# Null interactions take priority over interactions with specific areas because we
			# only want the area to get targeted if the `UseComponent` wants to interact with that
			# area specifically.
			for info in c.get_interactions(null):
				new_interactions.set(info.kind, UseInteractState.new(info, c, null))
	else:
		# Find the topmost thing that can be clicked on.
		for c in get_tree().get_nodes_in_group(&"interactable_component"):
			if not (c is InteractableComponent or c is LabBody) or not c.enable_interaction:
				continue

			for info: InteractInfo in c.get_interactions():
				var prev_state := new_interactions.get(info.kind) as ComponentInteractState
				var prev_component: Node2D = prev_state.target if prev_state else null

				if _interactable_component_is_preferred(prev_component, c):
					var s := ComponentInteractState.new(info, c)
					new_interactions.set(info.kind, s)

	for kind: InteractInfo.Kind in interactions.keys():
		var state: InteractState = interactions[kind]
		var new_state: InteractState = new_interactions.get(kind)

		# Retargeting to and interacting with this will do nothing.
		if not new_state: new_state = InteractState.new()

		# Never retarget an interaction while it's being pressed (this would introduce bizarre
		# behavior where you could click and drag something and it would show a button prompt
		# for something unrelated when the mouse moves to the wrong spot.
		if not state or state.is_pressed: continue

		# Interaction was retargeted.
		if not state._is_equivalent_to(new_state):
			state._stop_targeting()
			interactions[kind] = new_state
			new_state._start_targeting()

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

func clear_all_interaction_state() -> void:
	for kind: InteractInfo.Kind in interactions.keys():
		if interactions[kind].is_pressed:
			interactions[kind]._stop_interact()
			interactions[kind]._stop_targeting()
		interactions[kind] = InteractState.new()

	clear_interaction_stack()

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


class InteractState:
	var info: InteractInfo
	var is_pressed: bool = false


	func _init(p_info: InteractInfo = null) -> void:
		info = p_info

	# (virtual) Returns true if [param new_state] is effectively the same state as this (this
	# should ignore the state of [member is_pressed] and the kind, because states are already
	# separated by kind.
	func _is_equivalent_to(_new_state: InteractState) -> bool: return false

	# (virtual)
	func _start_targeting() -> void: pass
	# (virtual)
	func _stop_targeting() -> void: pass
	# (virtual)
	func _start_interact() -> void: pass
	# (virtual)
	func _stop_interact() -> void: pass

class SystemInteractState extends InteractState:
	var system: InteractableSystem


	func _init(p_info: InteractInfo, p_system: InteractableSystem) -> void:
		super(p_info)
		system = p_system

	func _is_equivalent_to(new_state: InteractState) -> bool:
		return new_state is SystemInteractState and new_state.system == system

	func _start_targeting() -> void: system.start_targeting(info.kind)
	func _stop_targeting() -> void: system.stop_targeting(info.kind)
	func _start_interact() -> void:
		if not info.allowed: return
		is_pressed = true
		system.start_interact(info.kind)
	func _stop_interact() -> void:
		if not is_pressed: return
		is_pressed = false
		system.stop_interact(info.kind)

class ComponentInteractState extends InteractState:
	# Can be an [InteractableComponent] or a [LabBody].
	var target: Node2D


	func _init(p_info: InteractInfo, p_target: Node2D) -> void:
		super(p_info)
		if p_target is InteractableComponent or p_target is LabBody:
			target = p_target

	func _is_equivalent_to(new_state: InteractState) -> bool:
		return new_state is ComponentInteractState and new_state.target == target

	func _start_targeting() -> void: target.start_targeting(info.kind)
	func _stop_targeting() -> void: target.stop_targeting(info.kind)
	func _start_interact() -> void:
		if not info.allowed: return
		is_pressed = true
		target.start_interact(info.kind)
	func _stop_interact() -> void:
		if not is_pressed: return
		is_pressed = false
		target.stop_interact(info.kind)

class UseInteractState extends InteractState:
	# Can be an [UseComponent] or a [LabBody].
	var source: Node2D
	var target: InteractableArea


	func _init(p_info: InteractInfo, p_source: Node2D, p_target: InteractableArea) -> void:
		super(p_info)
		if p_source is UseComponent or p_source is LabBody:
			source = p_source
		target = p_target

	func _is_equivalent_to(new_state: InteractState) -> bool:
		return new_state is UseInteractState and new_state.source == source and new_state.target == target

	func _start_targeting() -> void:
		if source is UseComponent: source.start_targeting(target, info.kind)
		elif source is LabBody: source.start_targeting(info.kind)
		if target: target.start_targeting(info.kind)

	func _stop_targeting() -> void:
		if source is UseComponent: source.stop_targeting(target, info.kind)
		elif source is LabBody: source.stop_targeting(info.kind)
		if target: target.stop_targeting(info.kind)

	func _start_interact() -> void:
		if not info.allowed: return
		is_pressed = true
		if source is UseComponent: source.start_use(target, info.kind)
		elif source is LabBody: source.start_interact(info.kind)
		if target: target.start_interact(info.kind)

	func _stop_interact() -> void:
		if not is_pressed: return
		is_pressed = false
		if source is UseComponent: source.stop_use(target, info.kind)
		elif source is LabBody: source.stop_interact(info.kind)
		if target: target.stop_interact(info.kind)
