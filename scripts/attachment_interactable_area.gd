## If an object has a child of type `AttachmentPoint`, then it can be attached to this node such
## that its attachment point is locked to the position of this node, held in place using a
## `RemoteTransform2D`. This node should never be rotated nor scaled.
class_name AttachmentInteractableArea
extends InteractableArea

enum GroupFilterType
{
	WHITELIST, ## Only allow attachment points/bodies that have at least one of the listed groups.
	BLACKLIST, ## Only allow attachment points/bodies that are not in any of the listed groups.
}

## Signal for what body has been placed when it has been placed somewhere.
signal object_placed(body: LabBody)
## Signal for what body has been removed from where it was previously placed.
signal object_removed(body: LabBody)


## If [code]false[/code], new objects can't be attached to this.
@export var allow_new_objects: bool = true
## If true, a ghost sprite of the object will appear where it would be attached.
@export var show_ghost_sprite: bool = true
## If true, then the attached object will be made invisible an impossible to pick up.
@export var hide_object: bool = false
## Prompt shown when hovering with an object that can be placed.
@export var place_prompt: String = "Place"
## If set to [code]true[/code], an object will be moved to the absolute z-index of this node when
## placed.
@export var set_object_z_index_on_place: bool = true

## If not null, this will be outlined when the user is targeting this.
@export var selectable_canvas_group: SelectableCanvasGroup = null

## Object currently attached. If this is set in the editor, then this object will automatically be
## attached when the game starts.
@export var contained_object: LabBody = null

@export_group("Object Group Filtering")
## Groups names used to filter what `AttachmentPoint`s are allowed to attach. Depending on whether
## `point_group_filter_type` is whitelist or blacklist, this will either allow or disallow
## attachment points with any of the listed groups.
@export var point_groups: Array[StringName] = []
## Determines how `point_groups` is used to determine what `AttachmentPoint`s are allowed.
@export var point_group_filter_type: GroupFilterType = GroupFilterType.WHITELIST

## Groups names used to filter what `LabBody`s are allowed to attach. Depending on whether
## `body_group_filter_type` is whitelist or blacklist, this will either allow or disallow bodies
## with any of the listed groups.
@export var body_groups: Array[StringName] = []
## Determines how `body_groups` is used to determine what `LabBody`s are allowed.
@export var body_group_filter_type: GroupFilterType = GroupFilterType.WHITELIST


var _remote_transform := RemoteTransform2D.new()
var _ghost_sprite: Node2D = null
var _offset: OffsetResult = null


func _enter_tree() -> void:
	call_deferred(&"add_child", _remote_transform)

func _ready() -> void:
	super()

	# The contained object may be set such that the simulation starts with the object locked in. In
	# that case, we have to manually place it. We have to set `contained_object` to null first,
	# however, since `place_object` expects that there be no contained object.
	if contained_object:
		if not contained_object.is_node_ready(): await contained_object.ready
		var obj := contained_object
		contained_object = null
		if not place_object(obj):
			push_warning("Failed to attach %s to %s" % [obj, self])

func _physics_process(_delta: float) -> void:
	# The user started dragging the contained object, so we release it.
	if contained_object != null and Interaction.held_body == contained_object:
		remove_object()

func _process(_delta: float) -> void:
	if contained_object and set_object_z_index_on_place:
		contained_object.z_index = DepthManager.get_base_z_index(Util.get_absolute_z_index(self))

## See [method InteractableArea.get_interactions]
func get_interactions() -> Array[InteractInfo]:
	if not contained_object and can_place(Interaction.held_body):
		return [InteractInfo.new(InteractInfo.Kind.PRIMARY, place_prompt)]
	else:
		return []

## See [method InteractableArea.start_targeting]
func start_targeting(_k: InteractInfo.Kind) -> void:
	if selectable_canvas_group: selectable_canvas_group.is_outlined = true

	if not Interaction.held_body: return

	var offset: Variant = _find_attachment_offset(Interaction.held_body)
	if not offset: return

	if show_ghost_sprite:
		_ghost_sprite = GhostCanvasGroup.create_from_sprites(Interaction.held_body)
		_ghost_sprite.position = offset.offset
		call_deferred(&"add_child", _ghost_sprite)

## See [method InteractableArea.stop_targeting]
func stop_targeting(_k: InteractInfo.Kind) -> void:
	if selectable_canvas_group: selectable_canvas_group.is_outlined = false
	if _ghost_sprite:
		_ghost_sprite.queue_free()
		_ghost_sprite = null

## See [method InteractableArea.start_interact]
func start_interact(_k: InteractInfo.Kind) -> void:
	_place_object_unchecked(Interaction.held_body)

## This is called to check if an object can snap into place within at attachment area.
func can_place(body: LabBody) -> bool:
	return allow_new_objects and _find_attachment_offset(body)

## Call this to attempt to place an object. Returns true if the object was placed.
func place_object(body: LabBody) -> bool:
	if not contained_object and can_place(body):
		_place_object_unchecked(body)
		return true

	return false

## Call this to remove the current object, if it is there. Returns true if an object was removed.
func remove_object() -> bool:
	if contained_object:
		_remote_transform.remote_path = NodePath()

		if hide_object:
			contained_object.show()
			contained_object.set_physics_mode(LabBody.PhysicsMode.FREE)
			contained_object.enable_interaction = true

		object_removed.emit(contained_object)
		if _offset.attachment_point:
			_offset.attachment_point.remove(self)
		_offset = null
		contained_object = null

		return true

	return false

func _place_object_unchecked(body: LabBody) -> void:
	contained_object = body

	contained_object.stop_dragging()

	if set_object_z_index_on_place:
		DepthManager.stop_managing(contained_object)
		contained_object.z_as_relative = false
		contained_object.z_index = DepthManager.get_base_z_index(Util.get_absolute_z_index(self))

	if hide_object:
		contained_object.hide()
		contained_object.enable_interaction = false
	contained_object.set_physics_mode(LabBody.PhysicsMode.FROZEN)

	_offset = _find_attachment_offset(contained_object)
	if _offset:
		# Since `LabObject`s do `set_deferred("linear_velocity")` in `stop_dragging`, it seems like
		# this can occasionally cause the position to be reset even after it has been initially set
		# by `_remote_transform` (I'm not 100% sure of this, but it seems to be the cause of the
		# incorrect position problem). Deferring this call will ensure that the position of the
		# object will be set after that and not broken.
		(func() -> void:
			_remote_transform.position = _offset.offset
			_remote_transform.remote_path = contained_object.get_path()
			if _offset.attachment_point:
				_offset.attachment_point.place(self)
		).call_deferred()

	object_placed.emit(body)

# Gives details about the offset that the object should be placed at, or null if the object cannot
# be placed. If there is a valid attachment point, then it will attach to that; otherwise, it will
# automatically attach to the bottom of `body`'s bounding box.
func _find_attachment_offset(body: LabBody) -> OffsetResult:
	var ap := _find_attachment_point(body)
	if ap: return OffsetResult.new(-ap.position, ap)

	if _matches_filter(body_groups, body_group_filter_type, body):
		var bbox := Util.get_bounding_box(body)
		# Bottom of the box.
		return OffsetResult.new(-bbox.position - bbox.size * Vector2(0.5, 1.0))

	return null

func _find_attachment_point(body: LabBody) -> AttachmentPoint:
	for a: AttachmentPoint in body.find_children("", "AttachmentPoint", false):
		if _matches_filter(point_groups, point_group_filter_type, a):
			return a

	return null

static func _matches_filter(groups: Array[StringName], method: GroupFilterType, node: Node2D) -> bool:
	var is_in_any_group := groups.any(func(g: StringName) -> bool: return node.is_in_group(g))
	if method == GroupFilterType.WHITELIST: return is_in_any_group
	else: return not is_in_any_group


class OffsetResult:
	var offset: Vector2 = Vector2.ZERO
	# Might be null if attaching directly to a body.
	var attachment_point: AttachmentPoint


	func _init(p_offset: Vector2, p_attachment_point: AttachmentPoint = null) -> void:
		offset = p_offset
		attachment_point = p_attachment_point
