class_name ElectricalTerminal
extends AttachmentInteractableArea


enum Charge { POSITIVE, NEGATIVE }


@export var side: Charge = Charge.POSITIVE
@export var electrical_component: ElectricalComponent


func on_place_object() -> void:
	super()
	if contained_object is ElectricalContact:
		contained_object.connected_terminal = self

func on_remove_object() -> void:
	super()
	if contained_object is ElectricalContact:
		contained_object.connected_terminal = null
