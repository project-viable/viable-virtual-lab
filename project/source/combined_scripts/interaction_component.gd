extends Node
class_name InteractionComponent

@export var interaction_area: InteractionArea # The parent should always have an InteractionArea if this component is used
@export var body: RigidBody2D # Should be the parent of this component

var interactable: PhysicsBody2D
var interactor: PhysicsBody2D

func _ready() -> void:
	interaction_area.area_entered.connect(InteractionHandler._on_interaction_area_entered.bind(body))
	interaction_area.area_exited.connect(InteractionHandler._on_interaction_area_exited.bind(body))
