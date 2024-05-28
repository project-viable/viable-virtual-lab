extends LabObject

var plugged_electrode = null

func TryInteract(others):
	for other in others:
		if(other.is_in_group("Current Contact")):
			# check if an electrode is currently plugged in
			if(plugged_electrode == null):
				# plug in the electrode
				plugged_electrode = other
				other.gravity_scale = 0.0
				# Reset the parent position to 0,0 otherwise the position is not set correctly
				other.get_parent().position = Vector2(0,0)
				other.position = position + get_parent().position
				
				get_parent().terminal_connected(self, other)
				
				if other.get_parent() != null:
					var parent = other.get_parent()
					var connection_device = self.get_parent()
					if "connections" in parent:
						if connection_device.has_method("terminal_connected"):
							# Both terminals connected, so a connection can be made with the contact
							if connection_device.terminal_connected(self, other):
								if not connection_device in parent.connections:
									parent.connections.append(connection_device)
							else:
								# Connection dropped
								parent.connections.erase(connection_device)
								# Set direction to neutral in contact wire
								if "current_direction" in parent:
									parent.current_direction = ContactWire.NEUTRAL
								if "current_source" in self.get_parent():
									# Remove current_source
									self.get_parent().current_source = null
						
					if "current_source" in self.get_parent():
						# Add current_source
						connection_device.current_source = true
					
					var curr_source = null
					var curr_target = null
					for connection in parent.connections:
						if connection.get_name() == "CurrentSource":
							curr_source = connection
						else:
							curr_target = connection
							
					if curr_source && curr_target:
						if curr_source.get_node("PosTerminal").plugged_electrode && \
						curr_target.get_node("PosTerminal").plugged_electrode:
							var source_parent = curr_source.get_node("PosTerminal").plugged_electrode.get_parent()
							var target_parent = curr_target.get_node("PosTerminal").plugged_electrode.get_parent()
							if source_parent == target_parent:
								parent.current_direction = ContactWire.FORWARD
							else:
								parent.current_direction = ContactWire.REVERSE
								
						if curr_source.get_node("NegTerminal").plugged_electrode && \
						curr_target.get_node("NegTerminal").plugged_electrode:
							var source_parent = curr_source.get_node("NegTerminal").plugged_electrode.get_parent()
							var target_parent = curr_target.get_node("NegTerminal").plugged_electrode.get_parent()
							if source_parent == target_parent:
								parent.current_direction = ContactWire.FORWARD
							else:
								parent.current_direction = ContactWire.REVERSE

func connected():
	return (plugged_electrode != null)

func _on_Area2D_body_exited(body):
	if(body == plugged_electrode):
		plugged_electrode.gravity_scale = 0.0
		plugged_electrode = null
