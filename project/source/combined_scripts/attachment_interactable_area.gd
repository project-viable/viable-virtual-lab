class_name AttachmentInteractableArea
extends InteractableArea
## If an object has a child of type `AttachmentPoint`, then it can be attached to this node such
## that its attachment point is locked to the position of this node, held in place using a
## `RemoteTransform2D`. This node should never be rotated nor scaled.


enum GroupFilterType
{
	WHITELIST, ## Only allow attachment points/bodies that have at least one of the listed groups.
	BLACKLIST, ## Only allow attachment points/bodies that are not in any of the listed groups.
}


signal object_placed(body: LabBody)
signal object_removed(body: LabBody)


## If true, a ghost sprite of the object will appear where it would be attached.
@export var show_ghost_sprite: bool = true
## If true, then the attached object will be made invisible an impossible to pick up.
@export var hide_object: bool = false
## Prompt shown when hovering with an object that can be placed.
@export var place_prompt: String = "Place"

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


func _ready() -> void:
	super()

	call_deferred(&"add_child", _remote_transform)

	# The contained object may be set such that the simulation starts with the object locked in. In
	# that case, we have to manually place it. We have to set `contained_object` to null first,
	# however, since `place_object` expects that there be no contained object.
	if contained_object:
		var obj := contained_object
		contained_object = null
		if not place_object(obj):
			push_warning("Failed to attach %s to %s" % [obj, self])

func _physics_process(_delta: float) -> void:
	# The user started dragging the contained object, so we release it.
	if Interaction.held_body == contained_object:
		remove_object()

func get_interactions() -> Array[InteractInfo]:
	if not contained_object and can_place(Interaction.held_body):
		return [InteractInfo.new(InteractInfo.Kind.PRIMARY, place_prompt)]
	else:
		return []

func start_targeting(_k: InteractInfo.Kind) -> void:
	if selectable_canvas_group: selectable_canvas_group.is_outlined = true

	if not Interaction.held_body: return

	var offset: Variant = _find_attachment_offset(Interaction.held_body)
	if offset is not Vector2: return

	if show_ghost_sprite:
		_ghost_sprite = Util.make_sprite_ghost(Interaction.held_body)
		_ghost_sprite.position = offset
		call_deferred(&"add_child", _ghost_sprite)

func stop_targeting(_k: InteractInfo.Kind) -> void:
	if selectable_canvas_group: selectable_canvas_group.is_outlined = false
	call_deferred(&"remove_child", _ghost_sprite)

func start_interact(_k: InteractInfo.Kind) -> void:
	_place_object_unchecked(Interaction.held_body)

func can_place(body: LabBody) -> bool:
	return _find_attachment_offset(body) is Vector2

func on_place_object() -> void:
	contained_object.stop_dragging()

	if hide_object:
		contained_object.hide()
		contained_object.enable_interaction = false
	contained_object.set_physics_mode(LabBody.PhysicsMode.KINEMATIC)

	var offset: Variant = _find_attachment_offset(contained_object)
	if offset is Vector2:
		_remote_transform.position = offset
		_remote_transform.remote_path = contained_object.get_path()

func on_remove_object() -> void:
	_remote_transform.remote_path = NodePath()

	if hide_object:
		contained_object.show()
		contained_object.set_physics_mode(LabBody.PhysicsMode.FREE)
		contained_object.enable_interaction = true

## Call this to attempt to place an object. Returns true if the object was placed.
func place_object(body: LabBody) -> bool:
	if not contained_object and can_place(body):
		_place_object_unchecked(body)
		return true

	return false

## Call this to remove the current object, if it is there. Returns true if an object was removed.
func remove_object() -> bool:
	if contained_object:
		on_remove_object()
		object_removed.emit(contained_object)
		contained_object = null
		return true

	return false

func _place_object_unchecked(body: LabBody) -> void:
	contained_object = body
	on_place_object()
	object_placed.emit(body)

# Gives the offset that the object should be placed at from this as a `Vector2`, or null if the
# object cannot be placed. If there is a valid attachment point, then it will attach to that;
# otherwise, it will automatically attach to the bottom of `body`'s bounding box. This has to
# return `Variant` because there's no other great way to make an optional `Vector2` without making
# a whole new class. It's fine here since this function is private.
func _find_attachment_offset(body: LabBody) -> Variant:
	var ap := _find_attachment_point(body)
	if ap: return -ap.position

	if _matches_filter(body_groups, body_group_filter_type, body):
		var bbox := Util.get_bounding_box(body)
		# Bottom of the box.
		return -bbox.position - bbox.size * Vector2(0.5, 1.0)

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
