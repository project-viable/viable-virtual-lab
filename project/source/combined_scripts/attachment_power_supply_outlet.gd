extends AttachmentInteractableArea

@export var expected_outlet_charge: Wire.Charge

## Emits a signal carrying the wire and the outlet's charge that wire was trying to interact with
signal wire_connected(wire: Wire, expected_outlet_charge: Wire.Charge)

var interacting_wire: Wire

func get_interactions() -> Array[InteractInfo]:
	var info: InteractInfo
	if can_place(Interaction.active_drag_component.body) and not contained_object:
		info = InteractInfo.new(InteractInfo.Kind.PRIMARY, "Connect Wire")
		return [info]

	return []

func start_interact(_k: InteractInfo.Kind) -> void:
	super(_k)
	if contained_object:
		print("A wire is already plugged in!")
	

func can_place(body: LabBody) -> bool:
	return body.is_in_group("contact_wire")

func _on_object_placed(body: LabBody) -> void:
	interacting_wire = body
	wire_connected.emit(contained_object, expected_outlet_charge)
