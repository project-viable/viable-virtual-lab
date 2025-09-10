extends AttachmentInteractableArea
class_name Terminal

enum Charge{
	POSITIVE,
	NEGATIVE
}

@export var terminal_charge: Charge

var connected_wire: Wire

## Emits a signal carrying the wire and the outlet's charge that wire was trying to interact with
signal wire_connected(wire: Wire, terminal_charge: Charge)

var interacting_wire: LabBody

func get_interactions() -> Array[InteractInfo]:
	var info: InteractInfo
	if can_place(Interaction.held_body):
		interacting_wire = Interaction.held_body
		info = InteractInfo.new(InteractInfo.Kind.PRIMARY, "Connect Wire")
		return [info]

	return []

func start_interact(_k: InteractInfo.Kind) -> void:
	if contained_object:
		print("A wire is already connected to the %s outlet!" % [Charge.keys()[terminal_charge]])
		interacting_wire.stop_dragging()
		return
		
	super(_k)
		

func can_place(body: LabBody) -> bool:
	return body.is_in_group("contact_wire")

func _on_object_placed(_body: LabBody) -> void:
	wire_connected.emit(contained_object, terminal_charge)
