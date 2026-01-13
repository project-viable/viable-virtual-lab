class_name DepthManagedNode2D
extends Node2D
## A [Node2D] whose z-index is automatically managed by [DepthManager] to be in the layer
## [member depth_layer]


@export var depth_layer: DepthManager.Layer = DepthManager.Layer.BENCH :
	set(v):
		depth_layer = v
		DepthManager.move_to_front_of_layer(self, depth_layer)



func _ready() -> void:
	# Call setter.
	depth_layer = depth_layer
