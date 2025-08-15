extends LabBody
class_name PowerSupply

# For simplicity sake, these will only toggle when the wire matches the outlet
# It is technically possible to mismatch on both the power supply and gel rig and
# the experiment will run just fine
@export var positive_connected: bool = false
@export var negative_connected: bool = false

signal activate_power_supply(voltage: float, time: int, is_circuit_ready: bool)

var wire_connected_to_positive_output: Wire
var wire_connected_to_negative_output: Wire

func _on_start_button_pressed() -> void:
	var circuit_ready: bool = positive_connected and negative_connected
	activate_power_supply.emit(180.0, 30, circuit_ready)


func _on_wire_connected(wire: Wire, target_outlet_charge: Wire.Charge) -> void:
	var is_charge_matching: bool = wire.charge == target_outlet_charge
	var is_outlet_positive: bool = target_outlet_charge == Wire.Charge.POSITIVE
	
	if is_charge_matching:
		if is_outlet_positive:
			positive_connected = true
			wire_connected_to_positive_output = wire
			
		else:
			negative_connected = true
			wire_connected_to_negative_output = wire
	
	else:
		if is_outlet_positive:
			print("Connecting a Negative to a Positive!")
			wire_connected_to_positive_output = wire
			
		else:
			print("Connecting a Positive to a Negative!")
			wire_connected_to_negative_output = wire

## Handle unplugging wires from the Power Supply
func unplug_handler(body: Node2D) -> void:
	var clicked_on_wire: Wire = body
	
	if wire_connected_to_positive_output and clicked_on_wire == wire_connected_to_positive_output: # Pulling out the wire from positive outlet
		positive_connected = false
		wire_connected_to_positive_output = null
		
		
	elif wire_connected_to_negative_output and clicked_on_wire == wire_connected_to_negative_output: # Pulling out the wire from negative outlet
		negative_connected = false
		wire_connected_to_negative_output = null
		
