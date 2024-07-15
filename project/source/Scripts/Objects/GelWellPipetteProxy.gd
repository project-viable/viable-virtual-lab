extends LabObject

var adoptedObject = null

func TryInteract(others):
	for other in others:
		if other is Pipette:
			AdoptPipette(other)
			return true
	return false

func AdoptPipette(pipette):
	#set the pipette up
	pipette.draggable = false
	pipette.global_position = global_position
	
	#set ourselves up
	draggable = true
	adoptedObject = pipette

func DragMove():
	global_position = Vector2(global_position.x, (get_global_mouse_position() - dragOffset).y)
	if adoptedObject:
		adoptedObject.global_position = global_position
