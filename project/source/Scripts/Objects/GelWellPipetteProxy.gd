extends LabObject

var adoptedObject = null
onready var startPos = position
var sideReleaseThreshold = 50 #in pixels, how far to the side the user should try to drag before we release the pipette

func TryInteract(others):
	for other in others:
		if other is Pipette and adoptedObject == null:
			AdoptPipette(other)
			return true
		elif other.is_in_group("GelWell"):
			if adoptedObject:
				adoptedObject.TryInteract([other])
				ReleasePipette()
				queue_free() #TODO: ideally you'd be able to try again, if you didn't break the well.
				return true
	return false

func AdoptPipette(pipette):
	#set the pipette up
	pipette.draggable = false
	pipette.global_position = global_position
	
	#set ourselves up
	draggable = true
	adoptedObject = pipette
	$AnimationPlayer.stop()
	#$Sprite.hide()

func ReleasePipette():
	#set the pipette up
	adoptedObject.draggable = true
	
	#set ourselves up
	position = startPos
	adoptedObject = null
	$Sprite.show()
	$AnimationPlayer.play()

func DragMove():
	#handle movement
	global_position = Vector2(global_position.x, (get_global_mouse_position() - dragOffset).y)
	if adoptedObject:
		adoptedObject.global_position = global_position
		
		#check if we should release the pipette:
		var xDifference = (get_global_mouse_position() - dragOffset).x - global_position.x
		if abs(xDifference) >= sideReleaseThreshold:
			var other = adoptedObject
			StopDragging()
			ReleasePipette()
			other.global_position = get_global_mouse_position() - dragOffset
