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


static var _pick_up_interaction := InteractInfo.new(InteractInfo.Kind.PRIMARY, "Pick up")
static var _put_down_interaction := InteractInfo.new(InteractInfo.Kind.PRIMARY, "Put down")


@export var physics_mode: PhysicsMode = PhysicsMode.FREE
## [SelectableCanvasGroup] that will be outlined when hovered and can be clicked to pick this
## object up. If set to [code]null[/code], this will automatically be set to the first
## [SelectableCanvasGroup] child of this [LabBody].
@export var interact_canvas_group: SelectableCanvasGroup = null
@export var enable_interaction: bool = true
## When set to [code]true[/code], the object will not follow the cursor reticle, though the hand
## cursor will stay in place.
@export var disable_follow_cursor: bool = false
## When set to [code]true[/code], the object can't be dropped. This might be used when zoomed in to
## prevent weird behavior.
@export var disable_drop: bool = false

## When dropped, this is the depth layer this body will be in.
@export var depth_layer_to_drop_in: DepthManager.Layer = DepthManager.Layer.BENCH


# Keep track of collision layers of any child physics objects. For example, the scale has a child
# `StaticBody2D` with one-way collision that acts as the surface for objects to be set on, which
# should be disabled while the object is being dragged.
var _child_physics_object_layers: Dictionary[PhysicsBody2D, int] = {}
var _offset: Vector2 = Vector2.ZERO
var _velocity: Vector2 = Vector2.ZERO

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
		_child_physics_object_layers.set(p, p.collision_layer | MANAGED_COLLISION_LAYERS_MASK)
		p.add_collision_exception_with(self)

	_update_physics_to_mode(physics_mode)

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint(): return

	if is_active():
		if abs(global_rotation) > 0.001:
			var is_rotating_clockwise := global_rotation < 0
			global_rotation -= global_rotation * delta * 50

			if is_rotating_clockwise: global_rotation = min(0.0, global_rotation)
			else: global_rotation = max(0.0, global_rotation)

		if not disable_follow_cursor:
			var dest_pos := to_global(_get_local_virtual_mouse_position() - _offset)
			_velocity = (dest_pos - global_position) / delta
			move_and_collide((dest_pos - global_position) * 30 * delta)

		Cursor.custom_hand_position = to_global(_offset)
	
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

# These do the same thing as the corresponding [InteractableComponent] functions.
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

	Cursor.mode = Cursor.Mode.CLOSED
	Cursor.use_custom_hand_position = true

## Can be safely called from elsewhere. Also cancels any interaction that was pressed down.
func stop_dragging() -> void:
	Interaction.held_body = null
	set_physics_mode(PhysicsMode.FALLING_THROUGH_SHELVES)
	Interaction.clear_interaction_stack()
	set_deferred(&"linear_velocity", _velocity / 5.0)

	DepthManager.move_to_front_of_layer(self, depth_layer_to_drop_in)

	Cursor.mode = Cursor.Mode.POINTER
	Cursor.use_custom_hand_position = false

func set_physics_mode(mode: PhysicsMode) -> void:
	if mode == physics_mode: return
	_update_physics_to_mode(mode)
	physics_mode = mode

func _update_physics_to_mode(mode: PhysicsMode) -> void:
	if mode == PhysicsMode.KINEMATIC:
		# Save physics states of child physics bodies.
		for p: PhysicsBody2D in _child_physics_object_layers.keys():
			_child_physics_object_layers[p] = p.collision_layer | MANAGED_COLLISION_LAYERS_MASK
			p.collision_layer = Util.bitwise_set(p.collision_layer, MANAGED_COLLISION_LAYERS_MASK, 0)
	else:
		for p: PhysicsBody2D in _child_physics_object_layers.keys():
			p.collision_layer = Util.bitwise_set(p.collision_layer, MANAGED_COLLISION_LAYERS_MASK,_child_physics_object_layers[p])

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

func _get_local_virtual_mouse_position() -> Vector2:
	return to_local(Cursor.virtual_mouse_position)
