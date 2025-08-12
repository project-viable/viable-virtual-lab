class_name AttachmentInteractableArea
extends ObjectSlotInteractableArea
## If an object has a child of type `AttachmentPoint`, then it can be attached to this node such
## that its attachment point is locked to the position of this node, held in place using a
## `RemoteTransform2D`. This node should never be rotated nor scaled.


@export var allowed_groups: Array[StringName] = []


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

	var ap := _find_attachment_point(Interaction.active_drag_component.body)
	if not ap: return

	_ghost_sprite = Util.make_sprite_ghost(Interaction.active_drag_component.body)
	_ghost_sprite.position = -ap.position
	call_deferred(&"add_child", _ghost_sprite)

func stop_targeting(_k: InteractInfo.Kind) -> void:
	call_deferred(&"remove_child", _ghost_sprite)

func can_place(body: LabBody) -> bool:
	return _find_attachment_point(body) != null

func on_place_object() -> void:
	Interaction.active_drag_component.stop_dragging()
	contained_object.start_dragging()

	var ap := _find_attachment_point(contained_object)
	if ap:
		_remote_transform.position = -ap.position
		_remote_transform.remote_path = contained_object.get_path()

func on_remove_object() -> void:
	_remote_transform.remote_path = NodePath()

func _find_attachment_point(body: LabBody) -> AttachmentPoint:
	for a: AttachmentPoint in body.find_children("", "AttachmentPoint", false):
		if not allowed_groups or allowed_groups.any(func(g: StringName) -> bool: return a.is_in_group(g)):
			return a
	
	return null
