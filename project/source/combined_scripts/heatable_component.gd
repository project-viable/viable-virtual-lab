extends Node
class_name HeatableComponent
@export var body: RigidBody2D # TODO: Change this when we have an actual substance component, for now the parent will be the placeholder

func heat(time: int) -> void:
	print("%s has heated up for %s seconds!" % [body.name, time])
	
