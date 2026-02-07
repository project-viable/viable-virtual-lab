class_name CameraRegionProvider
extends RegionProvider
## Represents the region exactly covering a [Camera2D]'s display rectangle.


## The camera whose display rectangle will be included in the region. If not set, this will be set
## automatically to the first child [Camera2D] of this node, if it exists.
@export var camera: Camera2D


func _ready() -> void:
	if not camera: camera = Util.find_child_of_type(self, Camera2D)

func get_region() -> Rect2:
	if camera: return Util.get_camera_world_rect(camera)
	else: return Rect2()
