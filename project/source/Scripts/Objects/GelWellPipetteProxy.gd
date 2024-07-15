extends LabObject

var adoptedObject = null
onready var startPos = global_position

func TryInteract(others):
	for other in others:
		if other is Pipette and adoptedObject == null:
			AdoptPipette(other)
			return true
		elif other.is_in_group("GelWell"):
			if adoptedObject:
				adoptedObject.TryInteract([other])
				ReleasePipette()
				return true
	return false

func AdoptPipette(pipette):
	#set the pipette up
	pipette.draggable = false
	pipette.global_position = global_position
	
	#set ourselves up
	draggable = true
	adoptedObject = pipette
	$AnimationPlayer.stop(true)

func ReleasePipette():
	#set the pipette up
	adoptedObject.draggable = true
	
	#set ourselves up
	queue_free() #TODO: ideally you'd be able to try again, if you didn't break the well.

func DragMove():
	global_position = Vector2(global_position.x, (get_global_mouse_position() - dragOffset).y)
	if adoptedObject:
		adoptedObject.global_position = global_position
