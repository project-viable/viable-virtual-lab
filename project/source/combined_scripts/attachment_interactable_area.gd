class_name AttachmentInteractableArea
extends InteractableArea
## If an object has a child of type `AttachmentPoint`, then it can be attached to this node such
## that its attachment point is locked to the position of this node, held in place using a
## `RemoteTransform2D`. This node should never be rotated nor scaled.


signal object_placed(body: LabBody)
signal object_removed(body: LabBody)


## If true, a ghost sprite of the object will appear where it would be attached.
@export var show_ghost_sprite: bool = true
## If true, then the attached object will be made invisible an impossible to pick up.
@export var hide_object: bool = false
@export var place_prompt: String = "Place"
@export var contained_object: LabBody = null

## If not null, this will be outlined when the user is targeting this.
@export var selectable_canvas_group: SelectableCanvasGroup = null

## Any attachment point, regardless of group, will be able to attach to this.
@export var allow_all_attachment_points: bool = false
## If `allow_all_attachment_points` is not set to true, then only attachment points with these
## groups will be allowed.
@export var allowed_point_groups: Array[StringName] = []

## Any `LabBody` will be able to directly attach to this.
@export var allow_all_bodies: bool = false
## If `allow_all_bodies` is not true, then only `LabBody`s in these groups can be attached.
@export var allowed_body_groups: Array[StringName] = []


# Drag component of the contained object. Used to enable and disable interaction with it.
var _drag_component: DragComponent = null

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
	if Interaction.active_drag_component and Interaction.active_drag_component.body == contained_object:
		remove_object()

func get_interactions() -> Array[InteractInfo]:
	if not contained_object and can_place(Interaction.active_drag_component.body):
		return [InteractInfo.new(InteractInfo.Kind.PRIMARY, place_prompt)]
	else:
		return []

func start_targeting(_k: InteractInfo.Kind) -> void:
	if selectable_canvas_group: selectable_canvas_group.is_outlined = true

	if not Interaction.active_drag_component or not Interaction.active_drag_component.body:
		return

	var offset: Variant = _find_attachment_offset(Interaction.active_drag_component.body)
	if offset is not Vector2: return

	if show_ghost_sprite:
		_ghost_sprite = Util.make_sprite_ghost(Interaction.active_drag_component.body)
		_ghost_sprite.position = offset
		call_deferred(&"add_child", _ghost_sprite)

func stop_targeting(_k: InteractInfo.Kind) -> void:
	if selectable_canvas_group: selectable_canvas_group.is_outlined = false
	call_deferred(&"remove_child", _ghost_sprite)

func start_interact(_k: InteractInfo.Kind) -> void:
	_place_object_unchecked(Interaction.active_drag_component.body)

func can_place(body: LabBody) -> bool:
	return _find_attachment_offset(body) is Vector2

func on_place_object() -> void:
	_drag_component = Interaction.active_drag_component
	if _drag_component:
		_drag_component.stop_dragging()
		if hide_object: _drag_component.enable_interaction = false

	if hide_object: contained_object.hide()
	contained_object.start_dragging()

	var offset: Variant = _find_attachment_offset(contained_object)
	if offset is Vector2:
		_remote_transform.position = offset
		_remote_transform.remote_path = contained_object.get_path()

func on_remove_object() -> void:
	_remote_transform.remote_path = NodePath()

	if hide_object:
		contained_object.show()
		contained_object.stop_dragging()
		_drag_component.enable_interaction = true

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

	if allow_all_bodies or allowed_body_groups.any(func(g: StringName) -> bool: return body.is_in_group(g)):
		var bbox := Util.get_bounding_box(body)
		# Bottom of the box.
		return -bbox.position - bbox.size * Vector2(0.5, 1.0)

	return null

func _find_attachment_point(body: LabBody) -> AttachmentPoint:
	for a: AttachmentPoint in body.find_children("", "AttachmentPoint", false):
		if allow_all_attachment_points or allowed_point_groups.any(func(g: StringName) -> bool: return a.is_in_group(g)):
			return a
	
	return null
