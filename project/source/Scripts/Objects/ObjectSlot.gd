extends LabObject

export var allowed_groups = ['Container', 'Liquid Container']
var held_object = null
var saved_grav_scale = 0.0
var saved_phys_mode = 0

func TryInteract(others):
	for other in others:
		for allowed_group in allowed_groups:
			if(other.is_in_group(allowed_group)):
				if(!filled()):
					held_object = other
					# prevent the area from detecting the single-frame coordinate snap on adding the child
					$Area2D.monitoring = false
					
					if (other.get_parent()):
						other.get_parent().call_deferred("remove_child", other)
					self.call_deferred("add_child", other)
					
					other.set_deferred("position", Vector2.ZERO)
					
					$Area2D.monitoring = true
					
					get_parent().slot_filled(self, other)

func filled():
	return (held_object != null)

func get_object():
	return held_object

func _on_GelBoatSlot_input_event(viewport, event, shape_idx):
	if (event.is_pressed()):
		if (!filled()):
			return

		if (held_object.get_parent()):
			held_object.get_parent().call_deferred("remove_child", held_object)
		GetCurrentModuleScene().call_deferred("add_child", held_object)
		get_parent().slot_emptied(self, held_object)
		held_object = null
