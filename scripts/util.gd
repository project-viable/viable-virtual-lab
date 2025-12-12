## General-purpose utility functions.
class_name Util


# Don't know if this is 100% correct, but it works for now. Get the "absolute" z-index of a node,
# taking into account relative z indices.
static func get_absolute_z_index(n: Node) -> int:
	if not (n is CanvasItem):
		return 0
	elif n.z_as_relative:
		return get_absolute_z_index(n.get_parent()) + n.z_index
	else:
		return n.z_index

# Get a bounding box for the full collision of a `CollisionObject2D`. This can be used, for
# example, to automatically find where the "bottom" of an object is. The resulting bounding box is
# in `obj`'s local coordinates.
static func get_bounding_box(obj: CollisionObject2D) -> Rect2:
	var rect := Rect2()
	var first := true
	for o in obj.get_shape_owners():
		if obj.is_shape_owner_disabled(o): continue
		var transform: Transform2D = obj.shape_owner_get_transform(o)
		for i in range(0, obj.shape_owner_get_shape_count(o)):
			var s := obj.shape_owner_get_shape(o, i)
			if first:
				rect = transform * s.get_rect()
				first = false
			else:
				rect = rect.merge(transform * s.get_rect())

	return rect

# Get the bounding box for [param obj]'s collision in global coordinates, axis-aligned.
static func get_global_bounding_box(obj: CollisionObject2D) -> Rect2:
	return obj.get_global_transform() * get_bounding_box(obj)

# Find the first child of `n` that is of type `type`. If it doesn't exist, return null.
static func find_child_of_type(n: Node, type: Variant) -> Node:
	for c in n.get_children():
		if is_instance_of(c, type): return c

	return null

## Find the first ancestor of [param n] of type [param type].
static func find_ancestor_of_type(n: Node, type: Variant) -> Node:
	while n.get_parent():
		n = n.get_parent()
		if is_instance_of(n, type): return n

	return null

# Lerps a smooth transition from [param from] to [param to] by interpolating the top left and
# bottom right corners. This is useful for easing a camera when the zoom changes.
static func lerp_rect2(from: Rect2, to: Rect2, t: float) -> Rect2:
	var result := Rect2()
	result.position = lerp(from.position, to.position, t)
	result.end = lerp(from.end, to.end, t)
	return result

# Get the viewport that [param camera] will render to (this is needed because the normal
# [method Camera2D.get_viewport] doesn't account for [member Camera2D.custom_viewport].
static func get_camera_viewport(camera: Camera2D) -> Viewport:
	if camera.custom_viewport: return camera.custom_viewport
	else: return camera.get_viewport()

# Get the rectangle displayed by [param camera] in world space.
static func get_camera_world_rect(camera: Camera2D) -> Rect2:
	var vp := get_camera_viewport(camera)
	if not vp: return Rect2()
	var rect := vp.get_visible_rect()
	rect.position = camera.global_position
	rect.size /= camera.zoom
	if camera.anchor_mode == Camera2D.ANCHOR_MODE_DRAG_CENTER:
		rect.position -= rect.size / 2
	return rect

# Set the displayed world rect of [param camera] without changing the anchor mode.
static func set_camera_world_rect(camera: Camera2D, rect: Rect2) -> void:
	var vp := get_camera_viewport(camera)
	if not vp: return
	camera.global_position = rect.position
	if camera.anchor_mode == Camera2D.ANCHOR_MODE_DRAG_CENTER:
		camera.global_position += rect.size / 2
	camera.zoom = vp.get_visible_rect().size / rect.size

# Return the smallest possible rectangle of the aspect ratio [param aspect] that fully contains
# [param rect]. If any space is added on the horizontal axis, then [param horizontal_weight]
# determines the position of [param rect] in the resulting rectangle; if [param horizontal_weight]
# is 0, then it will be all the way to the left, and if it is 1, then it will be all the way to the
# right. [param vertical_weight] does the same thing, but for the space on the top and bottom,
# respectively.
static func expand_to_aspect(rect: Rect2, aspect: float, horizontal_weight: float = 0.5, vertical_weight: float = 0.5) -> Rect2:
	var rect_aspect := rect.size.aspect()
	if rect_aspect < aspect:
		var extra_width := aspect * rect.size.y - rect.size.x
		return rect.grow_individual(horizontal_weight * extra_width, 0, (1 - horizontal_weight) * extra_width, 0)
	else:
		var extra_height := rect.size.x / aspect - rect.size.y
		return rect.grow_individual(0, vertical_weight * extra_height, 0, (1 - vertical_weight) *
	extra_height)


## Set bits in [param value] to bits in [param new_value] based on which bits are set in
## [param mask]. For example, if [param value] is [code]0000[/code], [param mask] is
## [code]0110[/code], and [param new_value] is [code]1010[/code], then this will return
## [code]0010[/code], since the mask indicates that only the middle two bits should be set.
static func bitwise_set(value: int, mask: int, new_value: int) -> int:
	return (mask & new_value) | (~mask & value)

## Convert the direction [param direction] in global coordinates to [param node]'s local
## coordinates. For example, [code]direction_to_local(n, Vector2.DOWN)[/code] will get the global
## down direction in [code]n[/code]'s local coordinates.
static func direction_to_local(node: Node2D, direction: Vector2) -> Vector2:
	return node.to_local(node.global_position + direction)

## Attempt to get the best possible [SelectableCanvasGroup] to be highlighted by a component that
## does interaction. If [param component]'s parent is a [LabBody] and its
## [member LabBody.interact_canvas_group] is not [code]null[/code], then it will use that.
## Otherwise, if [param component] has any siblings of type [SelectableCanvasGroup], then that will
## be used. Otherwise, return [code]null[/code].
static func try_get_best_selectable_canvas_group(component: Node) -> SelectableCanvasGroup:
	var p := component.get_parent()
	if p is LabBody and p.interact_canvas_group: return p.interact_canvas_group
	else: return find_child_of_type(p, SelectableCanvasGroup)

## The same as [code]Container::as_sortable_control[/code] in the engine, which isn't exposed to
## GDSCript.
static func as_sortable_control(node: Node) -> Control:
	var c := node as Control
	if not c or c.top_level or not c.visible: return null
	else: return c
