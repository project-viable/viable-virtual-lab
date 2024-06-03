extends LabObject

var fill_substance = null
var current_source = null
var mounted_container = null # This container reference should contain the substance to run

var current_reversed = false
var fill_requested = false

signal menu_closed

func TryInteract(others):
	for other in others:
		if other.is_in_group("Container") or other.is_in_group("Source Container"):
			# Open substance menu
			$FollowMenu/SubstanceMenu.visible = true
			
			yield(self, "menu_closed")
			
			if(fill_requested):
				# fill the setup with the container contents
				if(fill_substance == null):
					fill_substance = other.TakeContents()[0]
					$FollowMenu/SubstanceMenu.visible = false
				elif(other.CheckContents("Liquid Substance")):
					print('The setup is already filled.')
				else:
					print('The setup cannot be filled with that.')
				
				fill_requested = false

func run_current(voltage, time, print_text = false):
	# Check if current is reversed
	var current_reversed = current_reversed()
	
	if(current_source != null && $PosTerminal.connected() && $NegTerminal.connected()):
		if(fill_substance != null && fill_substance.is_in_group('Conductive')):
			if(mounted_container != null && mounted_container.is_in_group('Conductive')):
				# run current through the container
				var voltage_mod = -1 if (current_reversed) else 1 # this is a weird, Godot-style ternary
				mounted_container.run_current(voltage * voltage_mod, time)
				
				# update the gel display
				var content = $GelBoatSlot.get_object()
				if(content != null):
					if(content.is_in_group('Gel Boat')):
						$GelSimMenu/GelDisplay.update_bands(content.calculate_positions())
				
				if(!$GelSimMenu.visible):
					$GelSimMenu.visible = true
					$GelSimMenu/GelDisplay.open()
			else:
				if print_text:
					print('Running an empty or non-conductive setup...')
		else:
			if print_text:
				print('The conducting fill is either missing or non-conductive.')
	else:
		if print_text:
			print('There is no current source attached.')

func terminal_connected(terminal, contact):
	return $PosTerminal.connected() || $NegTerminal.connected()

func current_reversed():
	return true if ($PosTerminal.plugged_electrode.get_parent().current_direction == 0) else false

func slot_filled(slot, object):
	if(object.is_in_group('Gel Boat')):
		mounted_container = object
		var init_data = mounted_container.gel_status()
		$GelSimMenu/GelDisplay.init(init_data[0], init_data[1])

func slot_emptied(slot, object):
	mounted_container = null

func _on_SubstanceCloseButton_pressed():
	$FollowMenu/SubstanceMenu.visible = false
	emit_signal("menu_closed")

func _on_FillButton_pressed():
	fill_requested = true
	emit_signal("menu_closed")

func _on_CloseButton_pressed():
	$GelSimMenu.visible = false
	$GelSimMenu/GelDisplay.close()
