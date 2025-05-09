extends LabObject

var adopted_object: Pipette = null
@onready var start_pos: Vector2 = position
var side_release_threshold: float = 50 #in pixels, how far to the side the user should try to drag before we release the pipette

func try_interact(others: Array[LabObject]) -> bool:
	for other in others:
		if other is Pipette and adopted_object == null:
			adopt_pipette(other)
			return true
		elif other.is_in_group("GelWell"):
			if adopted_object:
				adopted_object.try_interact([other])
				release_pipette()
				queue_free() #TODO: ideally you'd be able to try again, if you didn't break the well.
				return true
	return false

func adopt_pipette(pipette: Pipette) -> void:
	#set the pipette up
	pipette.draggable = false
	pipette.global_position = global_position
	
	#set ourselves up
	draggable = true
	adopted_object = pipette
	$AnimationPlayer.stop()
	#$Sprite.hide()

func release_pipette() -> void:
	#set the pipette up
	adopted_object.draggable = true
	
	#set ourselves up
	position = start_pos
	adopted_object = null
	$Sprite2D.show()
	$AnimationPlayer.play()

func drag_move() -> void:
	#handle movement
	global_position = Vector2(global_position.x, (get_global_mouse_position() - drag_offset).y)
	if adopted_object:
		adopted_object.global_position = global_position
		
		#check if we should release the pipette:
		var x_difference: float = (get_global_mouse_position() - drag_offset).x - global_position.x
		if abs(x_difference) >= side_release_threshold:
			var other := adopted_object
			stop_dragging()
			release_pipette()
			other.global_position = get_global_mouse_position() - drag_offset
