## An object that can be dragged around.
class_name LabBody
extends RigidBody2D


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
	
	# Bodies with the freeze property set to true will initially not fall when the game starts
	if not freeze:
		stop_dragging()

# `start_dragging` and `stop_dragging` don't actually handle any drag logic; they just change the
# physics to allow for dragging.
func start_dragging() -> void:
	set_deferred(&"collision_mask", 0)
	set_deferred(&"freeze", true)

	for p: PhysicsBody2D in _child_physics_object_layers.keys():
		_child_physics_object_layers[p] = p.collision_layer
		p.set_deferred(&"collision_layer", 0)

func stop_dragging() -> void:
	# Contact wires will always be floating 
	if is_in_group(&"contact_wire"):
		return 
		
	set_deferred(&"collision_mask", 1)
	set_deferred(&"freeze", false)

	for p: PhysicsBody2D in _child_physics_object_layers.keys():
		p.set_deferred(&"collision_layer", _child_physics_object_layers[p])
