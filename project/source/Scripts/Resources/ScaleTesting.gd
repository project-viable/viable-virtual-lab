extends Node2D

func _unhandled_input(event):
	#check if there's any labobjects that need to deal with that input
	#Using the normal object picking (collision objects' input signals) doesn't give us the control we need
	if event.is_action_pressed("DragLabObject"):
		var castResult = get_world_2d().direct_space_state.intersect_point(get_global_mouse_position(), 32, [], 2)
		
		if len(castResult) > 0:
			#Drag a draggable object, if possible
			var dragging = false
			for object in castResult:
				if object['collider'].draggable:
					object['collider'].StartDragging()
					dragging = true
					get_viewport().set_input_as_handled()
					break
			
			#If none of them are draggable, then have a static one try to interact
			if not dragging:
				castResult[0]['collider'].OnUserAction()
				get_viewport().set_input_as_handled()
