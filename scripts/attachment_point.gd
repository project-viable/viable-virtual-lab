## Used as a point that can be attached to an `AttachmentInteractableArea`. If an attachment area
## has any groups in `allowed_groups`, then this node must be in that group to be attached.
class_name AttachmentPoint
extends Node2D


## Emitted when this attachment point is attached to the area [param area].
signal placed(area: AttachmentInteractableArea)
## Emitted when this attachment point is removed from the area [param area].
signal removed(area: AttachmentInteractableArea)


## Called by [AttachmentInteractableArea] when this point is attached to something.
func place(area: AttachmentInteractableArea) -> void:
	placed.emit(area)

## Called by [AttachmentInteractableArea] when this point is removed from something.
func remove(area: AttachmentInteractableArea) -> void:
	removed.emit(area)
