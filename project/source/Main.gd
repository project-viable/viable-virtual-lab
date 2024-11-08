extends Node2D

# TODO (update): This is essentially public, so we should consider using a convention to make that
# clear, like naming it in PascalCase.
var currentModuleScene: Node = null

@export var CheckStrategies: Array[MistakeChecker]

func CheckAction(params: Dictionary) -> void:
	for strategy in CheckStrategies:
		strategy.CheckAction(params)

#instanciates scene and adds it as a child of $Scene. Gets rid of any scene that's already been loaded, and hides the menu.
func SetScene(scene: PackedScene) -> void:
	LabLog.ClearLogs()
	for child in $Scene.get_children():
		child.queue_free()
	
	var newScene := scene.instantiate()
	$Scene.add_child(newScene)
	currentModuleScene = newScene
	#$Camera.Reset()

func GetDeepestSubsceneAt(pos: Vector2) -> Node:
	var result: Node = null
	
	var castResult := get_world_2d().direct_space_state.intersect_point(get_global_mouse_position(), 32, [], 2, false, true)
	if len(castResult) > 0:
		#We found results
		for object in castResult:
			if not object['collider'] is LabObject: #the allowed area of a subscene is not a LabObject
				if object['collider'].get_parent() is SubsceneManager: #^but its parent is the SubsceneManager
					if object['collider'].get_parent().subsceneActive and (result == null or object['collider'].get_parent().CountSubsceneDepth() > result.CountSubsceneDepth()):
						result = object['collider'].get_parent()
	
	return result

func _unhandled_input(event: InputEvent) -> void:
	###Check if they clicked a LabObject first
	#check if there's any labobjects that need to deal with that input
	#Using the normal object picking (collision objects' input signals) doesn't give us the control we need
	if event.is_action_pressed("DragLabObject"):
		var castResult := get_world_2d().direct_space_state.intersect_point(get_global_mouse_position(), 32, [], 2, true, true)
		
		if len(castResult) > 0:
			#We found results: now we need to make sure only objects in the subscene we clicked in (if any) can get this input
			var deepestSubscene := GetDeepestSubsceneAt(get_global_mouse_position())
			
			var pickOptions: Array[LabObject] = []
			for result in castResult:
				if result['collider'] is LabObject and (result['collider'].GetSubsceneManagerParent() == deepestSubscene or (result['collider'] == deepestSubscene and not result['collider'].subsceneActive)):
					pickOptions.append(result['collider'])
			
			var bestPick: LabObject = null
			for object in pickOptions:
				#draggables are better than non draggables, and high z indexes are tie breakers
				if bestPick == null or (
					object.draggable and not bestPick.draggable) or (
					object.z_index > bestPick.z_index and object.draggable == bestPick.draggable):
						bestPick = object
			
			if bestPick:
				if bestPick.draggable:
					bestPick.StartDragging()
				else:
					bestPick.OnUserAction()
				get_viewport().set_input_as_handled()
				return
	
	#If we've made it here, then we didn't need to do something with a LabObject
	###Now see if we should do something to the camera
#	if event.is_action_pressed("DragCamera") and GameSettings.mouseCameraDrag:
#		$Camera.StartDragging()
#
#	if event.is_action_pressed("CameraZoomIn"):
#		$Camera.ZoomIn()
#	if event.is_action_pressed("CameraZoomOut"):
#		$Camera.ZoomOut()
