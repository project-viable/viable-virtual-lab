class_name GhostCanvasGroup
extends CanvasGroup
## A [CanvasGroup] that displays its children as a "ghost".
##
## These are used for displaying where an object can be attached


static var _ghost_shader_material: ShaderMaterial


static func _static_init() -> void:
	_ghost_shader_material = ShaderMaterial.new()
	_ghost_shader_material.shader = preload("res://shaders/ghost.gdshader")


func _enter_tree() -> void:
	material = _ghost_shader_material.duplicate()

## Create a copy of all of the [Sprite2D] nodes among [param node] and all of its descendents, and
## create a new [GhostCanvasGroup] with them as children. Nodes with [member CanvasItem.visible]
## set to [code]false[/code] and their descendants will not be included. If a node is in the
## [code]ghost:always_include[/code] group, then its visibility will be ignored. If a node is in
## the [code]ghost:never_include[/code] group, then it and its descendants will always be skipped
## regardless of visibility.
static func create_from_sprites(node: Node2D) -> GhostCanvasGroup:
	var root := GhostCanvasGroup.new()

	var child := _copy_sprites(node)
	if child:
		child.position = Vector2.ZERO
		root.add_child(child)

	return root

static func _copy_sprites(node: Node2D) -> Node2D:
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
		var new_child := _copy_sprites(c)
		if new_child: new_node.add_child(new_child)

	if new_node is not Sprite2D and new_node.get_child_count() == 0:
		return null
	else:
		return new_node

