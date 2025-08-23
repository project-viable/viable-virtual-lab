## An object that can be dragged around.
class_name LabBody
extends RigidBody2D


enum PhysicsMode
{
	KINEMATIC, ## Not affected by gravity, but can interact with `InteractableArea`s when being dragged.
	FREE, ## Affected by gravity and will collide with shelves.
}


@export var physics_mode: PhysicsMode = PhysicsMode.FREE


# Keep track of collision layers of any child physics objects. For example, the scale has a child
# `StaticBody2D` with one-way collision that acts as the surface for objects to be set on, which
# should be disabled while the object is being dragged.
var _child_physics_object_layers: Dictionary[PhysicsBody2D, int] = {}
var _offset: Vector2 = Vector2.ZERO
var _velocity: Vector2 = Vector2.ZERO


func _ready() -> void:
	# Needed by `Interaction` to find this object.
	add_to_group(&"lab_body")

	# We need collisions in layer 2 so that interaction areas detect this object.
	freeze_mode = FREEZE_MODE_KINEMATIC
	collision_layer = 0b10

	for p: PhysicsBody2D in find_children("", "PhysicsBody2D", false):
		_child_physics_object_layers.set(p, p.collision_layer)

	set_physics_mode(physics_mode)

func _physics_process(delta: float) -> void:
	if is_active():
		if abs(global_rotation) > 0.001:
			var is_rotating_clockwise := global_rotation < 0
			global_rotation -= global_rotation * delta * 50

			if is_rotating_clockwise: global_rotation = min(0.0, global_rotation)
			else: global_rotation = max(0.0, global_rotation)

		var dest_pos := to_global(get_local_mouse_position() - _offset)
		_velocity = (dest_pos - global_position) / delta
		global_position = dest_pos

func start_dragging() -> void:
	Interaction.held_body = self
	set_physics_mode(PhysicsMode.KINEMATIC)

	# We can't just use `move_to_front` because it doesn't properly reorder the `_draw` calls,
	# whose specific order is required to determine which one is in front.
	var body_parent := get_parent()
	if body_parent:
		body_parent.call_deferred(&"remove_child", self)
		body_parent.call_deferred(&"add_child", self)

	_offset = get_local_mouse_position()

## Can be safely called from elsewhere. Also cancels any interaction that was pressed down.
func stop_dragging() -> void:
	Interaction.held_body = null
	set_physics_mode(PhysicsMode.FREE)
	Interaction.clear_interaction_stack()
	set_deferred(&"linear_velocity", _velocity / 5.0)

func set_physics_mode(mode: PhysicsMode) -> void:
	var new_collision_mask := 0
	var new_freeze := false

	match mode:
		PhysicsMode.KINEMATIC:
			new_collision_mask = 0
			new_freeze = true

			# Save physics states of child physics bodies.
			for p: PhysicsBody2D in _child_physics_object_layers.keys():
				_child_physics_object_layers[p] = p.collision_layer
				p.set_deferred(&"collision_layer", 0)

		PhysicsMode.FREE:
			new_collision_mask = 1
			new_freeze = false

			for p: PhysicsBody2D in _child_physics_object_layers.keys():
				p.set_deferred(&"collision_layer", _child_physics_object_layers[p])

	set_deferred(&"collision_mask", new_collision_mask)
	set_deferred(&"freeze", new_freeze)

func is_active() -> bool:
	return Interaction.held_body == self
