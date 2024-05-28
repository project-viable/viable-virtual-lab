tool
extends LabObject

var running = false
export (int) var time_delay = 0.005

func _ready():
	# Set the Sprite image
	$Sprite.set_texture($Viewport.get_texture())
	
	add_to_group("CurrentConductors", true)
	$CurrentConductor.SetCurrent(0)
	$CurrentConductor.SetVolts(0)
	$CurrentConductor.SetTime(0)

func TryInteract(others):
	pass

func terminal_connected(_terminal, _contact):
	return $PosTerminal.connected() || $NegTerminal.connected()

func _on_CurrentInput_value_changed(value):
	$CurrentConductor.SetCurrent(value)

func _on_VoltsInput_value_changed(value):
	$CurrentConductor.SetVolts(value)

func _on_TimeInput_value_changed(value):
	$CurrentConductor.SetTime(value)
	
func ToggleInputsEditable():
	$UserInput/CurrentInput.editable = !running
	$UserInput/VoltsInput.editable = !running
	$UserInput/TimeInput.editable = !running
	
	$UserInput/RunCurrent.disabled = running
	
func ToggleRunCurrentText():
	if running:
		$UserInput/RunCurrent.text = "RUNNING"
	else:
		$UserInput/RunCurrent.text = "START"

func _on_RunCurrent_pressed():
	if running:
		return
		
	if $CurrentConductor.GetTime() == 0:
		return
	
	var time_ran = 0
	
	# Update running state and button text
	running = !running
	ToggleRunCurrentText()
	ToggleInputsEditable()
	
	# Notify of errors only once
	var other_device = get_other_device()
	if(other_device.current_reversed()):
		LabLog.Warn("You reversed the currents. Running the gel like this will run the substance off the gel.")
	if($CurrentConductor.GetVolts() < 120):
		LabLog.Warn("The voltage was set too low. This made the gel run slower. Set it to 120V for this lab.")
	if($CurrentConductor.GetVolts() > 120):
		LabLog.Warn("The voltage was set too high. This made the gel run faster. Set it to 120V for this lab.")
	
	# This calls run_current on the designated device at an equally timed interval
	while time_ran <= $CurrentConductor.GetTime():
		var timestep = get_physics_process_delta_time()
		# Get the connection
		if $PosTerminal.connected() && $NegTerminal.connected():
			if other_device.has_method("run_current"):
				
				other_device.run_current($CurrentConductor.GetVolts(), $CurrentConductor.GetCurrent(), timestep)
				
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
	print(time_ran, " ", $CurrentConductor.GetTime())

func get_other_device():
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
