extends Node2D
## Handles connection logic for objects that can have contact wires be
## connected to their terminals.
## A signal is emitted that checks whether or not the object has valid wire connections
class_name WireConnectableComponent

## an object that can be dragged around and interacted with
@export var body: LabBody

@export var correct_wire_placement: bool = false

## Voltage currently running through this. It will be negative if the direction is reversed.
@export_custom(PROPERTY_HINT_NONE, "suffix:V") var voltage: float = 0

## A signal that emits when a wire is connected to both terminals
signal terminals_connected(is_every_terminal_connected: bool)

## Sets the state of connection when the wire is connected to the positive terminal
var wire_connected_to_positive_terminal: Wire:
	set(value):
		wire_connected_to_positive_terminal = value
		_check_connection_state()

## Sets the state of connection when the wire is connected to the negative terminal
var wire_connected_to_negative_terminal: Wire:
	set(value):
		wire_connected_to_negative_terminal = value
		_check_connection_state()

## Checks if a matching connection is made with the wire and outlet.
## Otherwise, warn the user that the connections may be incorrect
func on_wire_connected(wire: Wire, target_terminal_charge: Terminal.Charge) -> void:
	var is_terminal_positive: bool = target_terminal_charge == Terminal.Charge.POSITIVE
	wire.connected_component = self

	if is_terminal_positive:
		wire_connected_to_positive_terminal = wire
		if (wire_connected_to_positive_terminal != get_node("%RedContactWire")):
			if (wire_connected_to_positive_terminal != get_node("%RedContactWire2")):
				correct_wire_placement = true
				Game.report_log.update_event("true", "electrode_correct_placement")
	else:
		wire_connected_to_negative_terminal = wire
		if (wire_connected_to_positive_terminal != get_node("%BlackContactWire")):
			if (wire_connected_to_positive_terminal != get_node("%BlackContactWire2")):
				correct_wire_placement = true
				Game.report_log.update_event("true", "electrode_correct_placement")

# Handle unplugging wires
## Handles the state of wire connections when the wires are unplugged
func unplug_handler(body: Node2D) -> void:
	var clicked_on_wire: Wire = body
	clicked_on_wire.connected_component = null

	if wire_connected_to_positive_terminal and clicked_on_wire == wire_connected_to_positive_terminal: # Pulling out the wire from positive outlet
		wire_connected_to_positive_terminal = null

	elif wire_connected_to_negative_terminal and clicked_on_wire == wire_connected_to_negative_terminal: # Pulling out the wire from negative outlet
		wire_connected_to_negative_terminal = null

## Checks if terminals are all connected, and if so, a singal is emitted.
func _check_connection_state() -> void:
	if wire_connected_to_positive_terminal and wire_connected_to_negative_terminal:
		terminals_connected.emit(true)

	else:
		terminals_connected.emit(false)

## Returns the state of the connection in the positive terminal
func get_positive_terminal_wire() -> Wire:
	return wire_connected_to_positive_terminal

## Returns the state of the connection in the negative terminal
func get_negative_terminal_wire() -> Wire:
	return wire_connected_to_negative_terminal
