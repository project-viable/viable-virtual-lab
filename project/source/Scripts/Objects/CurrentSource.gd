@tool
extends LabObject

var running := false
@export var time_delay: float = 0.005

func _ready() -> void:
	super()
	add_to_group("CurrentConductors", true)
	$CurrentConductor.SetVolts(0)
	$CurrentConductor.SetTime(0)

func TryInteract(others: Array[LabObject]) -> bool:
	return false

func terminal_connected(_terminal: LabObject, _contact: LabObject) -> bool:
	return $PosTerminal.connected() || $NegTerminal.connected()

func _on_VoltsInput_value_changed(value: float) -> void:
	$CurrentConductor.SetVolts(value)

func _on_TimeInput_value_changed(value: float) -> void:
	$CurrentConductor.SetTime(value)
	
func ToggleInputsEditable() -> void:
	$UserInput/VoltsInput.editable = !running
	$UserInput/TimeInput.editable = !running	
	
func ToggleRunCurrentText() -> void:
	if running:
		$UserInput/RunCurrent.text = "STOP"
	else:
		$UserInput/RunCurrent.text = "START"
		
func current_reversed() -> bool:
	# TODO (update): This if statement is pointless.
	return true if ($PosTerminal.plugged_electrode.get_parent().current_direction == 0) else false

func _on_RunCurrent_pressed() -> void:
	if running:
		running = false
		ToggleRunCurrentText()
		ToggleInputsEditable()
		return
		
	if $CurrentConductor.GetTime() == 0:
		return
	
	var other_device := get_other_device()
	
	if other_device.has_method('able_to_run_current'):
		if other_device.able_to_run_current():
			var time_ran := 0.0
			var voltage_mod: float = -1 if (current_reversed()) else 1
			# Notify of potential errors only once
			ReportAction([self, other_device], "runCurrent", {'voltage': $CurrentConductor.GetVolts() * voltage_mod})
			
			# Update running state and button text
			running = true
			ToggleRunCurrentText()
			ToggleInputsEditable()
			
			# This calls run_current on the designated device at an equally timed interval
			# This loop will also stop short of the desired time if the user presses "STOP"
			while time_ran <= $CurrentConductor.GetTime():
				if !running:
					break
				var timestep := get_physics_process_delta_time()
				# Get the connection
				if $PosTerminal.connected() && $NegTerminal.connected():
					if other_device.has_method("run_current"):
						
						other_device.run_current($CurrentConductor.GetVolts() * voltage_mod, timestep)
						
						time_ran += timestep
						
						await get_tree().create_timer(time_delay).timeout
						
					else:
						print("Other device ", other_device, " needs a run_current() method")
						break
				else:
					print("At least one terminal is disconnected")
					break
			
			running = false
			ToggleRunCurrentText()
			ToggleInputsEditable()
	else:
		print("Device cannot run current")

func get_other_device() -> Node:
	if $PosTerminal == null || $NegTerminal == null:
		return
	var pos_parent: ContactWire = $PosTerminal.plugged_electrode.get_parent()
	var neg_parent: ContactWire = $NegTerminal.plugged_electrode.get_parent()
	
	# Union of both terminal connections
	var connections := pos_parent.connections
	for connection in neg_parent.connections:
		if not connections.has(connection):
			connections.append(connection)
	
	if connections.size() != 2:
		print("Need two devices. Currently have ", connections.size())
		return null
	
	return (connections[0] if self != connections[0] else connections[1])
