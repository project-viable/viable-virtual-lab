extends LabObject

export (String) var allowed_group = 'Container'
var held_object = null
var saved_grav_scale = 0.0
var saved_phys_mode = 0

func TryInteract(others):
	for other in others:
		if(other.is_in_group(allowed_group)):
			if(!filled()):
				held_object = other
				
				# prevent the area from detecting the single-frame coordinate snap on adding the child
				$Area2D.monitoring = false
				
				GetCurrentModuleScene().call_deferred("remove_child", other)
				self.call_deferred("add_child", other)
				
				other.set_deferred("position", Vector2.ZERO)
				
				$Area2D.monitoring = true
				
				saved_grav_scale = other.gravity_scale
				other.set_deferred("gravity_scale", 0.0)
				saved_phys_mode = other.mode
				
				get_parent().slot_filled(self, other)

func filled():
	return (held_object != null)

func get_object():
	return held_object

func _on_GelBoatSlot_input_event(viewport, event, shape_idx):
	if (event.is_pressed()):
		if (!filled()):
			return

		held_object.set_deferred("gravity_scale", saved_grav_scale)
		held_object.set_deferred("mode", saved_phys_mode)

		self.call_deferred("remove_child", held_object)
		GetCurrentModuleScene().call_deferred("add_child", held_object)

		get_parent().slot_emptied(self, held_object)
		held_object = null
