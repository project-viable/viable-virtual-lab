tool
extends LabObject

var running = false
export (int) var time_delay = 0.005

func _ready():
	# Set the Sprite image
	$Sprite.set_texture($Viewport.get_texture())
	
	add_to_group("CurrentConductors", true)
	$CurrentConductor.SetVolts(0)
	$CurrentConductor.SetTime(0)

func TryInteract(others):
	pass

func terminal_connected(_terminal, _contact):
	return $PosTerminal.connected() || $NegTerminal.connected()

func _on_VoltsInput_value_changed(value):
	$CurrentConductor.SetVolts(value)

func _on_TimeInput_value_changed(value):
	$CurrentConductor.SetTime(value)
	
func ToggleInputsEditable():
	$UserInput/VoltsInput.editable = !running
	$UserInput/TimeInput.editable = !running
	
	$UserInput/RunCurrent.disabled = running
	
func ToggleRunCurrentText():
	if running:
		$UserInput/RunCurrent.text = "RUNNING"
	else:
		$UserInput/RunCurrent.text = "START"
		
func current_reversed():
	return true if ($PosTerminal.plugged_electrode.get_parent().current_direction == 0) else false

func _on_RunCurrent_pressed():
	if running:
		return
		
	if $CurrentConductor.GetTime() == 0:
		return
	
	var other_device = get_other_device()
	if other_device.has_method('able_to_run_current'):
		if other_device.able_to_run_current():
			var time_ran = 0
			var voltage_mod = -1 if (current_reversed()) else 1
			# Notify of potential errors only once
			GetCurrentScene().CurrentChecker([$CurrentConductor.GetVolts() * voltage_mod])
			
			# Update running state and button text
			running = !running
			ToggleRunCurrentText()
			ToggleInputsEditable()
	
			# This calls run_current on the designated device at an equally timed interval
			while time_ran <= $CurrentConductor.GetTime():
				var timestep = get_physics_process_delta_time()
				# Get the connection
				if $PosTerminal.connected() && $NegTerminal.connected():
					if other_device.has_method("run_current"):
						
						other_device.run_current($CurrentConductor.GetVolts() * voltage_mod, timestep)
						
						time_ran += timestep
						
						yield(get_tree().create_timer(time_delay), "timeout")
						
						
					else:
						print("Other device ", other_device, " needs a run_current() method")
						break
				else:
					print("At least one terminal is disconnected")
					break
			
			running = !running
			ToggleRunCurrentText()
			ToggleInputsEditable()

func get_other_device():
	if $PosTerminal == null || $NegTerminal == null:
		return
	var pos_parent = $PosTerminal.plugged_electrode.get_parent()
	var neg_parent = $NegTerminal.plugged_electrode.get_parent()
	
	# Union of both terminal connections
	var connections = pos_parent.connections
	for connection in neg_parent.connections:
		if not connections.has(connection):
			connections.append(connection)
	
	if connections.size() != 2:
		print("Need two devices. Currently have ", connections.size())
		return null
	
	return (connections[0] if self != connections[0] else connections[1])
