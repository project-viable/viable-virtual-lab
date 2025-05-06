@tool
extends Area2D
class_name LabBoundary

var x_bounds: Vector2
var y_bounds: Vector2

func _ready() -> void:
	var position: Vector2 = $CollisionShape2D.global_position
	var extents: Vector2 = $CollisionShape2D.shape.extents
	
	x_bounds[0] = -extents.x + position.x
	x_bounds[1] = extents.x + position.x
	
	y_bounds[0] = -extents.y + position.y
	y_bounds[1] = extents.y + position.y
