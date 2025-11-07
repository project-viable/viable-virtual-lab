class_name SubstanceAccessArea
extends Area2D


## The display polygon to take from.
@export var substance_display: SubstanceDisplayPolygon


func _ready() -> void:
	collision_layer = 0b1000
