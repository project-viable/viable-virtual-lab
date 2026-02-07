class_name ObjectRegionProvider
extends RegionProvider
## Represents a region covering the bounding boxes of an explicit set of [CollisionShape2D]s.


## The region will include the bounding boxes of all objects in [member objects].
@export var objects: Array[CollisionObject2D] = []


func get_region() -> Rect2:
	var has_rect := false
	var region := Rect2()

	for o in objects:
		var rect := Util.get_global_bounding_box(o)
		if has_rect:
			region = region.merge(rect)
		else:
			region = rect
			has_rect = true

	return region
