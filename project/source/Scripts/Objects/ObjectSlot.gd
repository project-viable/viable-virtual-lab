extends LabObject

export (String) var allowed_group = 'Container'
var held_object = null
var saved_grav_scale = 0.0
var saved_phys_mode = 0

func TryInteract(others):
	for other in others:
		if(other.is_in_group(allowed_group)):
			if(held_object == null):
				# prevent the area from detecting the single-frame coordinate snap on adding the child
				$Area2D.monitoring = false
				
				other.get_parent().remove_child(other)
				self.add_child(other)
				other.position = Vector2.ZERO
				
				$Area2D.monitoring = true
				
				held_object = other
				saved_grav_scale = other.gravity_scale
				other.gravity_scale = 0.0
				saved_phys_mode = other.mode
				other.mode = 3 # set to kinematic mode for the duration of its time in the slot
				
				get_parent().slot_filled(self, other)

func filled():
	return (held_object != null)

func get_object():
	return held_object

func _on_Area2D_body_exited(body):
	if(body == held_object):
		held_object.gravity_scale = saved_grav_scale
		held_object.mode = saved_phys_mode
		
		self.call_deferred("remove_child", held_object)
		get_parent().get_parent().add_child(held_object)
		
		get_parent().slot_emptied(self, held_object)
		held_object = null
