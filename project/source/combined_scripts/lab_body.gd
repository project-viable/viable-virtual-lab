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


func _ready() -> void:
	#  We need collisions in layer 2 so that interaction areas detect this object.
	freeze_mode = FREEZE_MODE_KINEMATIC
	collision_layer = 0b10

	for p: PhysicsBody2D in find_children("", "PhysicsBody2D", false):
		_child_physics_object_layers.set(p, p.collision_layer)

	set_physics_mode(physics_mode)

# `start_dragging` and `stop_dragging` don't actually handle any drag logic; they just change the
# physics to allow for dragging.
func start_dragging() -> void: set_physics_mode(PhysicsMode.KINEMATIC)
func stop_dragging() -> void: set_physics_mode(PhysicsMode.FREE)

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
