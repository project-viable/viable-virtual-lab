class_name WireAttachmentInteractableArea
extends AttachmentInteractableArea
## Allows wires to be attached to a [CircuitComponent] to connect them together.


## The [CircuitComponent] that wires will be attached to.
@export var circuit_component: CircuitComponent
@export var terminal_side: CircuitComponent.TerminalSide


func _enter_tree() -> void:
	super()
	object_placed.connect(_on_object_placed)
	object_removed.connect(_on_object_removed)

# We must only be able to place wires.
func can_place(body: LabBody) -> bool:
	return super(body) and body is Wire

func _on_object_placed(body: LabBody) -> void:
	if body is Wire:
		body.connected_circuit_component = circuit_component
		body.connected_terminal_side = terminal_side

		if body.other_end:
			circuit_component.connect_to(body.other_end.connected_circuit_component, terminal_side, body.other_end.connected_terminal_side)

func _on_object_removed(body: LabBody) -> void:
	if body is Wire:
		body.connected_circuit_component = null
		circuit_component.connect_to(null, terminal_side, terminal_side)
