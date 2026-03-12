class_name ZoomExclusiveArea
extends ExclusiveArea2D
## An exclusive area providing access to a subscene and region to zoom in on. Zooming is handled by
## the object entering.


@export var camera: SubsceneCamera
## Node whose position is where the entering object should start.
@export var entry_node: Node2D
## Provides the region that should be zoomed in on. If not set, this will be set to the first
## [RegionProvider] child of this node.
@export var region_provider: RegionProvider


func _ready() -> void:
	super()
	if not region_provider: region_provider = Util.find_child_of_type(self, RegionProvider)
