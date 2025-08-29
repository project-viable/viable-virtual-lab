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
# example, to automatically find where the "bottom" of an object is.
static func get_bounding_box(obj: CollisionObject2D) -> Rect2:
	var rect := Rect2()
	var first := true
	for o in obj.get_shape_owners():
		var transform: Transform2D = obj.shape_owner_get_transform(o)
		for i in range(0, obj.shape_owner_get_shape_count(o)):
			var s := obj.shape_owner_get_shape(o, i)
			if first:
				rect = transform * s.get_rect()
				first = false
			else:
				rect = rect.merge(transform * s.get_rect())

	return rect

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
