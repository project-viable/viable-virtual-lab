extends Node2D
class_name InteractionComponent

## Acts as a base class that handles connecting the InteractionArea node to the InteractionHandler singleton
## Also handles initial interaction setup in _process
## All interaction nodes should extend this one

@export var interaction_area: InteractionArea # The parent should always have an InteractionArea if this component is used
@export var body: RigidBody2D # Should be the parent of this component

var interactable: PhysicsBody2D
var interactor: PhysicsBody2D

func _ready() -> void:
	interaction_area.area_entered.connect(InteractionHandler._on_interaction_area_entered.bind(body))
	interaction_area.area_exited.connect(InteractionHandler._on_interaction_area_exited.bind(body))

func _process(_delta: float) -> void:
	if body == GameState.interactable: # Something is interacting with the body
		interactable = body
		interactor = GameState.interactor
		interact(interactor)
		GameState.interactable = null

# Virtual. Should be implemented in the node that extends this class
func interact(_interactor: PhysicsBody2D) -> void:
	assert(false, "%s currently does not handle any interactions. \
	Please add interact() to the %s's script that extends InteractionComponent." % [interactable.name, interactable.name])
