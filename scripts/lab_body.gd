## An object that can be dragged around.
class_name LabBody
extends RigidBody2D


enum PhysicsMode
{
	KINEMATIC, ## Not affected by gravity, but can interact with `InteractableArea`s when being dragged, and will collide with boundaries.
	FREE, ## Affected by gravity and will collide with shelves and the lab boundary.
	FALLING_THROUGH_SHELVES, ## Affected by gravity, but does not interact with shelves. In this mode, `physics_mode` will automatically be set to `FREE` when the body is no longer overlapping with a shelf.
}


# Mask for the collision layer bits actually managed by [LabBody]. Other bits can be freely changed
# and won't be affected.
const MANAGED_COLLISION_LAYERS_MASK: int = 0b111
# Same as [member CharacterBody2D.max_slides].
const MAX_SLIDES: int = 5


static var _pick_up_interaction := InteractInfo.new(InteractInfo.Kind.PRIMARY, "Pick up")
static var _put_down_interaction := InteractInfo.new(InteractInfo.Kind.PRIMARY, "Put down")

## Determines the physics of an object whether it free or kinematic
@export var physics_mode: PhysicsMode = PhysicsMode.FREE
## [SelectableCanvasGroup] that will be outlined when hovered and can be clicked to pick this
## object up. If set to [code]null[/code], this will automatically be set to the first
## [SelectableCanvasGroup] child of this [LabBody].
@export var interact_canvas_group: SelectableCanvasGroup = null

## Boolean value that enables interactions when set to [code]true[/code]
@export var enable_interaction: bool = true
## When set to [code]true[/code], the object will not follow the cursor reticle, though the hand
## cursor will stay in place.
@export var disable_follow_cursor: bool = false
## When set to [code]true[/code], the object can't be dropped. This might be used when zoomed in to
## prevent weird behavior.
@export var disable_drop: bool = false
## When set to [code]true[/code], the object won't automatically rotate to right itself.
@export var disable_rotate_upright: bool = false

## When dropped, this is the depth layer this body will be in.
@export var depth_layer_to_drop_in: DepthManager.Layer = DepthManager.Layer.BENCH


## Keeps track of collision layers of any child physics objects. For example, the scale has a child
## [StaticBody2D] with one-way collision that acts as the surface for objects to be set on, which
## should be disabled while the object is being dragged.
var _child_physics_object_layers: Dictionary[PhysicsBody2D, int] = {}
var _offset: Vector2 = Vector2.ZERO
# In the coordinate system of [member interact_canvas_group] so it follows the object visually
# (e.g., when a flask is swirled, the hand will follow it).
var _hand_offset := Vector2.ZERO
var _velocity: Vector2 = Vector2.ZERO
var _mouse_motion_since_last_tick := Vector2.ZERO

## Set by [Main] to [code]true[/code] when the cursor starts overlapping this.
var is_moused_over: bool = false


func _ready() -> void:
	if Engine.is_editor_hint(): return

	# Needed by `Interaction` to find this object.
	add_to_group(&"interactable_component")

	if not interact_canvas_group:
		interact_canvas_group = Util.find_child_of_type(self, SelectableCanvasGroup)

	DepthManager.move_to_front_of_layer(self, depth_layer_to_drop_in)

	freeze_mode = FREEZE_MODE_KINEMATIC
	# We need collisions in layer 3 so that interaction areas detect this object.
	collision_layer = 0b100
	continuous_cd = RigidBody2D.CCD_MODE_CAST_SHAPE

	for p: PhysicsBody2D in find_children("", "PhysicsBody2D", false):
		_child_physics_object_layers.set(p, p.collision_layer & MANAGED_COLLISION_LAYERS_MASK)
		p.add_collision_exception_with(self)

	_update_physics_to_mode(physics_mode)

	# Accumulate mouse motion to move the object.
	Cursor.virtual_mouse_moved_relative.connect(
		func(v: Vector2) -> void: _mouse_motion_since_last_tick += v)
	Cursor.virtual_mouse_moved.connect(_on_virtual_mouse_moved)

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint(): return

	var mouse_motion_this_tick := _mouse_motion_since_last_tick
	_mouse_motion_since_last_tick = Vector2.ZERO

	if is_active():
		if not disable_rotate_upright and abs(global_rotation) > 0.001:
			var is_rotating_clockwise := global_rotation < 0
			var new_global_rotation := global_rotation
			new_global_rotation -= global_rotation * delta * 50

			if is_rotating_clockwise: set_global_rotation_about_cursor(min(0.0, new_global_rotation))
			else: set_global_rotation_about_cursor(max(0.0, new_global_rotation))

		if not disable_follow_cursor:
			_velocity = mouse_motion_this_tick / delta
			move_and_slide(Cursor.clamp_relative_to_screen(mouse_motion_this_tick))

		Cursor.virtual_mouse_position = get_global_hand_pos()

		if interact_canvas_group:
			Cursor.virtual_mouse_position = interact_canvas_group.to_global(_hand_offset)
		else:
			Cursor.virtual_mouse_position = to_global(_offset)
	
	if physics_mode == PhysicsMode.FALLING_THROUGH_SHELVES:
		var old_mask := collision_mask
		# Only test collision with shelves.
		collision_mask = 0b010
		var is_over_shelf := test_move(transform, Vector2.ZERO)
		collision_mask = old_mask

		if not is_over_shelf:
			set_physics_mode(PhysicsMode.FREE)

func get_interactions() -> Array[InteractInfo]:
	if is_active():
		if disable_drop: return []
		else: return [_put_down_interaction]
	else:
		return [_pick_up_interaction]

func start_targeting(_k: InteractInfo.Kind) -> void:
	if not is_active() and interact_canvas_group:
		interact_canvas_group.is_outlined = true
		Cursor.mode = Cursor.Mode.OPEN

func stop_targeting(_kind: InteractInfo.Kind) -> void:
	if interact_canvas_group:
		interact_canvas_group.is_outlined = false
		Cursor.mode = Cursor.Mode.POINTER

func start_interact(_kind: InteractInfo.Kind) -> void:
	if is_active(): stop_dragging()
	else: start_dragging()

func stop_interact(_kind: InteractInfo.Kind) -> void:
	pass

## These do the same thing as the corresponding [InteractableComponent] functions.
func is_hovered() -> bool: return is_moused_over

func get_draw_order() -> int:
	if interact_canvas_group:
		return interact_canvas_group.draw_order_this_frame
	return 0


func get_absolute_z_index() -> int:
	if interact_canvas_group:
		return Util.get_absolute_z_index(interact_canvas_group)
	return 0

func start_dragging() -> void:
	Interaction.held_body = self
	set_physics_mode(PhysicsMode.KINEMATIC)

	DepthManager.move_to_front_of_layer(self, DepthManager.Layer.HELD)

	_offset = _get_local_virtual_mouse_position()
	if interact_canvas_group:
		_hand_offset = _get_local_virtual_mouse_position(interact_canvas_group)

	Cursor.mode = Cursor.Mode.CLOSED
	Cursor.automatically_move_with_mouse = false

## Can be safely called from elsewhere. Also cancels any interaction that was pressed down.
func stop_dragging() -> void:
	Interaction.held_body = null
	set_physics_mode(PhysicsMode.FALLING_THROUGH_SHELVES)
	Interaction.clear_interaction_stack()
	set_deferred(&"linear_velocity", _velocity / 5.0)

	DepthManager.move_to_front_of_layer(self, depth_layer_to_drop_in)

	Cursor.mode = Cursor.Mode.POINTER
	Cursor.automatically_move_with_mouse = true

func set_physics_mode(mode: PhysicsMode) -> void:
	if mode == physics_mode: return
	_update_physics_to_mode(mode)
	physics_mode = mode

## Behaves similarly to [method CharacterBody2D.move_and_slide].
func move_and_slide(motion: Vector2) -> void:
	var cur_motion := motion
	for _i in MAX_SLIDES:
		var result := move_and_collide(cur_motion)
		if not result or result.get_remainder().is_zero_approx():
			break

		cur_motion = result.get_remainder().slide(result.get_normal())
		# Don't keep moving if we're not moving in the same direction as the original motion vector.
		if cur_motion.dot(motion) <= 0:
			break

## If this body is currently being held, rotate it to the global angle [param angle] about the
## point where it was grabbed.
func set_global_rotation_about_cursor(angle: float) -> void:
	var old_hand_pos := get_global_hand_pos()
	global_rotation = angle
	global_position += old_hand_pos - get_global_hand_pos()

## Get the position that the hand cursor should be while holding this body, in global coordinates.
## If this body is held, then this will be the position where it was grabbed. Otherwise, it will
## just be its [member Node2D.global_position].
func get_global_hand_pos() -> Vector2:
	if not is_active(): return global_position
	elif interact_canvas_group: return interact_canvas_group.to_global(_hand_offset)
	else: return to_global(_offset)

func _update_physics_to_mode(mode: PhysicsMode) -> void:
	if mode == PhysicsMode.KINEMATIC:
		# Save physics states of child physics bodies.
		for p: PhysicsBody2D in _child_physics_object_layers.keys():
			_child_physics_object_layers[p] = p.collision_layer & MANAGED_COLLISION_LAYERS_MASK
			p.collision_layer = Util.bitwise_set(p.collision_layer, MANAGED_COLLISION_LAYERS_MASK, 0)
	else:
		for p: PhysicsBody2D in _child_physics_object_layers.keys():
			p.collision_layer = Util.bitwise_set(p.collision_layer, MANAGED_COLLISION_LAYERS_MASK, _child_physics_object_layers[p])

	# We always have the boundary collision enabled by default.
	var new_collision_mask := 0b001
	var new_gravity_scale := 1.0

	match mode:
		PhysicsMode.KINEMATIC:
			new_gravity_scale = 0.0
			set_deferred(&"linear_velocity", Vector2.ZERO)
		PhysicsMode.FREE:
			# Collide with shelves.
			new_collision_mask |= 0b010

	collision_mask = Util.bitwise_set(collision_mask, MANAGED_COLLISION_LAYERS_MASK, new_collision_mask)
	gravity_scale = new_gravity_scale

func is_active() -> bool:
	return Interaction.held_body == self

func _get_local_virtual_mouse_position(node: Node2D = self) -> Vector2:
	return node.to_local(Cursor.virtual_mouse_position)

func _on_virtual_mouse_moved(_old: Vector2, _new: Vector2) -> void:
	# Handle external motion through pure brute force. This is *also* called when we set
	# `virtual_mouse_position` in `_physics_process`, but we use `Engine.is_in_physics_frame` as a
	# bit of a hack to make sure we don't do this unnecessarily.
	if is_active() and not Engine.is_in_physics_frame() \
			and not Cursor.virtual_mouse_position.is_equal_approx(to_global(_offset)):
		global_position += Cursor.virtual_mouse_position - to_global(_offset)
