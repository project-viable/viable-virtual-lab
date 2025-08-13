class_name ObjectContainmentInteractableArea
extends ObjectSlotInteractableArea
## An object slot that fully contains an object (rather than just attaching it, like
## `AttachmentInteractableArea`). This is done by making the object invisible and its drag component
## uninteractable. There is no way to remove the object except by directly calling the
## `remove_object` function.


## This will be outlined when an object is (possibly) about to be inserted.
@export var selectable_canvas_group: SelectableCanvasGroup

## See `object_slot_interactable_area.gd` for an expalantion.
@export var allow_all_bodies: bool = false
## See `object_slot_interactable_area.gd` for an expalantion.
@export var allowed_body_groups: Array[StringName] = []


# Drag component of the contained object. Used to enable and disable interaction with it.
var _drag_component: DragComponent = null


func start_targeting(_k: InteractInfo.Kind) -> void:
	if selectable_canvas_group: selectable_canvas_group.is_outlined = true

func stop_targeting(_k: InteractInfo.Kind) -> void:
	if selectable_canvas_group: selectable_canvas_group.is_outlined = false

func can_place(body: LabBody) -> bool:
	return allow_all_bodies or allowed_body_groups.any(func(g: StringName) -> bool: return body.is_in_group(g))

func on_place_object() -> void:
	_drag_component = Interaction.active_drag_component
	if _drag_component:
		_drag_component.stop_dragging()
		_drag_component.enable_interaction = false

	contained_object.hide()
	contained_object.start_dragging()

func on_remove_object() -> void:
	contained_object.show()
	contained_object.stop_dragging()
	_drag_component.enable_interaction = true
