class_name GroupRegionProvider
extends RegionProvider
## Represents a region covering the bounding boxes of nearby [CollisionObject2D]s in one of a set of
## groups.


## If including the bounding box of an object would extend the edge of the region to more than
## [member search_radius] units away from this node in either the x or y direction, then that
## object will not be included in the region.
@export var search_radius: float = 200

## Objects of type [CollisionObject2D] that are in one of the groups in [member groups] are
## candidates for inclusion in the region.
@export var groups: Array[StringName] = []


func get_region() -> Rect2:
	var has_rect := false
	var region := Rect2()

	var search_rect := Rect2(global_position - search_radius * Vector2.ONE, 2 * search_radius * Vector2.ONE)

	for g in groups:
		for o in get_tree().get_nodes_in_group(g):
			if o is CollisionObject2D:
				var rect := Util.get_global_bounding_box(o)
				if not search_rect.encloses(rect): continue

				if has_rect:
					region = region.merge(rect)
				else:
					region = rect
					has_rect = true

	return region
