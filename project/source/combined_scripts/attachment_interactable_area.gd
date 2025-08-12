class_name AttachmentInteractableArea
extends ObjectSlotInteractableArea
## If an object has a child of type `AttachmentPoint`, then it can be attached to this node such
## that its attachment point is locked to the position of this node, held in place using a
## `RemoteTransform2D`. This node should never be rotated nor scaled.


@export var allowed_point_groups: Array[StringName] = []
@export var allowed_body_groups: Array[StringName] = []


var _remote_transform := RemoteTransform2D.new()
var _ghost_sprite: Node2D = null


func _ready() -> void:
	super()
	call_deferred(&"add_child", _remote_transform)

func _physics_process(_delta: float) -> void:
	# The user started dragging the contained object, so we release it.
	if Interaction.active_drag_component and Interaction.active_drag_component.body == contained_object:
		remove_object()

func start_targeting(_k: InteractInfo.Kind) -> void:
	if not Interaction.active_drag_component or not Interaction.active_drag_component.body:
		return

	var offset: Variant = _find_attachment_offset(Interaction.active_drag_component.body)
	if offset is not Vector2: return

	_ghost_sprite = Util.make_sprite_ghost(Interaction.active_drag_component.body)
	_ghost_sprite.position = offset
	call_deferred(&"add_child", _ghost_sprite)

func stop_targeting(_k: InteractInfo.Kind) -> void:
	call_deferred(&"remove_child", _ghost_sprite)

func can_place(body: LabBody) -> bool:
	return _find_attachment_offset(body) is Vector2

func on_place_object() -> void:
	Interaction.active_drag_component.stop_dragging()
	contained_object.start_dragging()

	var offset: Variant = _find_attachment_offset(contained_object)
	if offset:
		_remote_transform.position = offset
		_remote_transform.remote_path = contained_object.get_path()

func on_remove_object() -> void:
	_remote_transform.remote_path = NodePath()

# Gives the offset that the object should be placed at from this as a `Vector2`, or null if the
# object cannot be placed. If there is a valid attachment point, then it will attach to that;
# otherwise, it will automatically attach to the bottom of `body`'s bounding box. This has to
# return `Variant` because there's no other great way to make an optional `Vector2` without making
# a whole new class. It's fine here since this function is private.
func _find_attachment_offset(body: LabBody) -> Variant:
	var ap := _find_attachment_point(body)
	if ap: return -ap.position

	if not allowed_body_groups or allowed_body_groups.any(func(g: StringName) -> bool: return body.is_in_group(g)):
		var bbox := Util.get_bounding_box(body)
		# Bottom of the box.
		return -bbox.position - bbox.size * Vector2(0.5, 1.0)

	return null


func _find_attachment_point(body: LabBody) -> AttachmentPoint:
	for a: AttachmentPoint in body.find_children("", "AttachmentPoint", false):
		if not allowed_point_groups or allowed_point_groups.any(func(g: StringName) -> bool: return a.is_in_group(g)):
			return a
	
	return null
