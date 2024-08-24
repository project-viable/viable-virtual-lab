tool
extends LabObject
class_name ObjectSlot

export var allowed_groups = ['Container', 'Liquid Container']
var held_object = null

func TryInteract(others):
	for other in others:
		for allowed_group in allowed_groups:
			if(other.is_in_group(allowed_group)):
				if(!filled()):
					other.active = false
					held_object = other
					
					if (other.get_parent()):
						other.get_parent().call_deferred("remove_child", other)
					self.call_deferred("add_child", other)
					
					other.set_deferred("position", Vector2.ZERO)
					
					get_parent().slot_filled(self, other)

func filled():
	return (held_object != null)

func get_object():
	return held_object

func _on_ObjectSlot_input_event(viewport, event, shape_idx):
	if (event.is_pressed()):
		if (!filled()):
			return
		held_object.active = true
		if (held_object.get_parent()):
			held_object.get_parent().call_deferred("remove_child", held_object)
		GetCurrentModuleScene().call_deferred("add_child", held_object)
		get_parent().slot_emptied(self, held_object)
		held_object = null
