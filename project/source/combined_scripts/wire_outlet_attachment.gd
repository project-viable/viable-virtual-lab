extends AttachmentInteractableArea

@export var outlet_charge: Wire.Charge

## Emits a signal carrying the wire and the outlet's charge that wire was trying to interact with
signal wire_connected(wire: Wire, outlet_charge: Wire.Charge)

var interacting_wire: DragComponent

func get_interactions() -> Array[InteractInfo]:
	var info: InteractInfo
	if can_place(Interaction.active_drag_component.body):
		interacting_wire = Interaction.active_drag_component
		info = InteractInfo.new(InteractInfo.Kind.PRIMARY, "Connect Wire")
		return [info]

	return []

func start_interact(_k: InteractInfo.Kind) -> void:
	if contained_object:
		print("A wire is already connected to the %s outlet!" % [Wire.Charge.keys()[outlet_charge]])
		interacting_wire.stop_dragging()
		return
		
	super(_k)
		

func can_place(body: LabBody) -> bool:
	return body.is_in_group("contact_wire")

func _on_object_placed(_body: LabBody) -> void:
	wire_connected.emit(contained_object, outlet_charge)
