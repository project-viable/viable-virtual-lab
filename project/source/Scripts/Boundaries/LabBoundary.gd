@tool
extends Area2D
class_name LabBoundary

var xBounds: Vector2
var yBounds: Vector2

func _ready():
	var position = $CollisionShape2D.global_position
	var extents = $CollisionShape2D.shape.extents
	
	xBounds[0] = -extents.x + position.x
	xBounds[1] = extents.x + position.x
	
	yBounds[0] = -extents.y + position.y
	yBounds[1] = extents.y + position.y
