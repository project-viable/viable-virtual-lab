## General-purpose utility functions.
class_name Util


static var _ghost_shader_material: ShaderMaterial


static func _static_init() -> void:
	_ghost_shader_material = ShaderMaterial.new()
	_ghost_shader_material.shader = preload("res://shaders/ghost.gdshader")

# Don't know if this is 100% correct, but it works for now. Get the "absolute" z-index of a node,
# taking into account relative z indices.
static func get_absolute_z_index(n: Node) -> int:
	if not (n is CanvasItem):
		return 0
	elif n.z_as_relative:
		return get_absolute_z_index(n.get_parent()) + n.z_index
	else:
		return n.z_index

# Makes a "ghost" node of every `Sprite2D` in a tree rooted at `node`. This can be used to show how
# an object will be placed before it is placed.
static func make_sprite_ghost(node: Node2D) -> Node2D:
	var root := CanvasGroup.new()
	root.material = _ghost_shader_material

	var child := _make_sprite_ghost_impl(node)
	if child:
		child.position = Vector2.ZERO
		root.add_child(child)

	return root

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

static func _make_sprite_ghost_impl(node: Node2D) -> Node2D:
	# Skip invisible nodes or ones in the "ghost:never_include" group. Never skip nodes in the
	# "ghost:always_include" group.
	if not node.is_in_group(&"ghost:always_include") \
			and (not node.visible or node.is_in_group(&"ghost:never_include")):
		return null

	var new_node: Node2D = null
	if node is Sprite2D:
		new_node = Sprite2D.new()
		# TODO: Is there a better way to correctly duplicate these properties?
		new_node.region_enabled = node.region_enabled
		new_node.region_rect = node.region_rect
		new_node.offset = node.offset
		new_node.texture = node.texture
	else:
		new_node = Node2D.new()

	new_node.transform = node.transform

	for c: Node2D in node.find_children("", "Node2D", false):
		var new_child := _make_sprite_ghost_impl(c)
		if new_child: new_node.add_child(new_child)

	if new_node is not Sprite2D and new_node.get_child_count() == 0:
		return null
	else:
		return new_node

# Find the first child of `n` that is of type `type`. If it doesn't exist, return null.
static func find_child_of_type(n: Node, type: Variant) -> Node:
	for c in n.get_children():
		if is_instance_of(c, type): return c

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
