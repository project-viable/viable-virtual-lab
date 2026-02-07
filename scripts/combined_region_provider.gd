class_name CombinedRegionProvider
extends RegionProvider
## Represents a region including the regions of all [RegionProvider] children of this node. Also
## allows optional padding on each side.


@export var left_padding: float = 0
@export var top_padding: float = 0
@export var right_padding: float = 0
@export var bottom_padding: float = 0


func get_region() -> Rect2:
	var has_rect := false
	var region := Rect2()

	for o: RegionProvider in find_children("", "RegionProvider", false):
		var sub_region := o.get_region()
		if not sub_region.has_area(): continue

		if has_rect:
			region = region.merge(sub_region)
		else:
			region = sub_region
			has_rect = true

	if has_rect:
		return region.grow_individual(left_padding, top_padding, right_padding, bottom_padding)
	else:
		return Rect2()
