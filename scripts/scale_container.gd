@tool
class_name ScaleContainer
extends Container
## A container that scales and exactly fits around its children.
##
## This is needed because raw scaled controls can behave weirdly when scaled, and can't retain their
## scale when put into a container.


@export_custom(PROPERTY_HINT_LINK, "") var child_scale: Vector2 = Vector2.ONE :
	set(v):
		child_scale = v
		update_minimum_size()
		queue_sort()


func _notification(what: int) -> void:
	if what == NOTIFICATION_SORT_CHILDREN:
		reset_size()
		for n in get_children():
			var c := Util.as_sortable_control(n)
			if c:
				c.pivot_offset = Vector2.ZERO
				# Cheap way to position the element. Just shrink it in the top left.
				fit_child_in_rect(c, Rect2(Vector2.ZERO, c.get_combined_minimum_size()))
				c.scale = child_scale


func _get_minimum_size() -> Vector2:
	var max_size := Vector2.ZERO

	for n in get_children():
		var c := Util.as_sortable_control(n)
		if c:
			max_size = max_size.max(c.get_combined_minimum_size() * child_scale)

	return max_size
