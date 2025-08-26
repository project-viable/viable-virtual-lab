extends LabBody
class_name WireConnectable
## Handles connection logic for objects that can have contact wires be 
## connected to their outlets.
## A signal is emitted that checks whether or not the object has valid wire connections
## For simplicity sake, a valid connection is when the charge of the wire matches the 
## charge of the outlet


# True if a positive contact wire is connected to the positive outlet
@export var positive_connected: bool = false:
	set(value):
		positive_connected = value
		_check_connection_state()

# True if a negative contact wire is connected to the negative outlet
@export var negative_connected: bool = false:
	set(value):
		negative_connected = value
		_check_connection_state()

# Emitted whenevr a wire is connected to an outlet
signal valid_connection(is_valid: bool)

var _wire_connected_to_positive_output: Wire
var _wire_connected_to_negative_output: Wire

# Checks if a matching connection is made with the wire and outlet
# Otherwise, warn the user that the connections may be incorrect
func on_wire_connected(wire: Wire, target_outlet_charge: Wire.Charge) -> void:
	var is_charge_matching: bool = wire.charge == target_outlet_charge
	var is_outlet_positive: bool = target_outlet_charge == Wire.Charge.POSITIVE
	
	if is_charge_matching:
		if is_outlet_positive:
			positive_connected = true
			_wire_connected_to_positive_output = wire
			
		else:
			negative_connected = true
			_wire_connected_to_negative_output = wire
	
	else:
		if is_outlet_positive:
			print("Connecting a Negative to a Positive!")
			_wire_connected_to_positive_output = wire

		else:
			print("Connecting a Positive to a Negative!")
			_wire_connected_to_negative_output = wire
			
# Handle unplugging wires
func unplug_handler(body: Node2D) -> void:
	var clicked_on_wire: Wire = body
	
	if _wire_connected_to_positive_output and clicked_on_wire == _wire_connected_to_positive_output: # Pulling out the wire from positive outlet
		positive_connected = false
		_wire_connected_to_positive_output = null
		
		
	elif _wire_connected_to_negative_output and clicked_on_wire == _wire_connected_to_negative_output: # Pulling out the wire from negative outlet
		negative_connected = false
		_wire_connected_to_negative_output = null

# Check if the wires are correctly connected to their respective outlets and emit a signal 
func _check_connection_state() -> void:
	if positive_connected and negative_connected:
		valid_connection.emit(true)
	else:
		valid_connection.emit(false)
