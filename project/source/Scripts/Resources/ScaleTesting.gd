extends Node2D

func _unhandled_input(event: InputEvent) -> void:
	#check if there's any labobjects that need to deal with that input
	#Using the normal object picking (collision objects' input signals) doesn't give us the control we need
	if event.is_action_pressed("DragLabObject"):
		var cast_params := PhysicsPointQueryParameters2D.new()
		cast_params.position = get_global_mouse_position()
		cast_params.collision_mask = 0b10
		var cast_result := get_world_2d().direct_space_state.intersect_point(cast_params)

		if len(cast_result) > 0:
			#Drag a draggable object, if possible
			var dragging := false
			for object in cast_result:
				if object['collider'].draggable:
					object['collider'].start_dragging()
					dragging = true
					get_viewport().set_input_as_handled()
					break
			
			#If none of them are draggable, then have a static one try to interact
			if not dragging:
				cast_result[0]['collider'].on_user_action()
				get_viewport().set_input_as_handled()
