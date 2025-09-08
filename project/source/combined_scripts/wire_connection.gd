extends Node2D
class_name WireConnectableComponent
## Handles connection logic for objects that can have contact wires be 
## connected to their terminals.
## A signal is emitted that checks whether or not the object has valid wire connections

@export var body: LabBody

signal terminals_connected(is_every_terminal_connected: bool)

var wire_connected_to_positive_terminal: Wire:
	set(value):
		wire_connected_to_positive_terminal = value
		_check_connection_state()
		
var wire_connected_to_negative_terminal: Wire:
	set(value):
		wire_connected_to_negative_terminal = value
		_check_connection_state()

# Checks if a matching connection is made with the wire and outlet
# Otherwise, warn the user that the connections may be incorrect
func on_wire_connected(wire: Wire, target_terminal_charge: Terminal.Charge) -> void:
	var is_terminal_positive: bool = target_terminal_charge == Terminal.Charge.POSITIVE
	wire.connected_component = self
	
	if is_terminal_positive:
		wire_connected_to_positive_terminal = wire
		
	else:
		wire_connected_to_negative_terminal = wire
	
# Handle unplugging wires
func unplug_handler(body: Node2D) -> void:
	var clicked_on_wire: Wire = body
	clicked_on_wire.connected_component = null
	
	if wire_connected_to_positive_terminal and clicked_on_wire == wire_connected_to_positive_terminal: # Pulling out the wire from positive outlet
		wire_connected_to_positive_terminal = null
		
	elif wire_connected_to_negative_terminal and clicked_on_wire == wire_connected_to_negative_terminal: # Pulling out the wire from negative outlet
		wire_connected_to_negative_terminal = null

# Check if terminals are all connected, if so emit a signal.
func _check_connection_state() -> void:
	if wire_connected_to_positive_terminal and wire_connected_to_negative_terminal:
		terminals_connected.emit(true)
		
	else:
		terminals_connected.emit(false)

func get_positive_terminal_wire() -> Wire:
	return wire_connected_to_positive_terminal
	
func get_negative_terminal_wire() -> Wire:
	return wire_connected_to_negative_terminal
