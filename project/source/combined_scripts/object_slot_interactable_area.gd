class_name ObjectSlotInteractableArea
extends InteractableArea
## An interactable area that allows objects to be placed. The object doesn't actually get affected
## when it's placed, but it's possible to add behavior for that in classes deriving from
## `ObjectSlotInteractableArea`.


signal object_placed(body: LabBody)
signal object_removed(body: LabBody)


@export var contained_object: LabBody = null
@export var place_prompt: String = "Place"


func _ready() -> void:
	super()

	# The contained object may be set such that the simulation starts with the object locked in. In
	# that case, we have to manually place it. We have to set `contained_object` to null first,
	# however, since `place_object` expects that there be no contained object.
	if contained_object:
		var obj := contained_object
		contained_object = null
		if not place_object(obj):
			print("Warning: failed to put object %s in slot %s" % [obj, self])

func get_interactions() -> Array[InteractInfo]:
	if not contained_object and can_place(Interaction.active_drag_component.body):
		return [InteractInfo.new(InteractInfo.Kind.PRIMARY, place_prompt)]
	else:
		return []

func start_interact(_k: InteractInfo.Kind) -> void:
	_place_object_unchecked(Interaction.active_drag_component.body)

## (virtual) determine whether the given object can be placed in this slot. The object will be
## placed only if this function returns true and there is not already a contained object.
func can_place(_body: LabBody) -> bool: return false

## (virtual) called when an object is placed. `contained_object` will always be set before this is
## called.
func on_place_object() -> void: pass

## (virtual) called when an object is removed. `contained_object` is set to null only *after* this
## function returns, so it can be accessed there.
func on_remove_object() -> void: pass

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
