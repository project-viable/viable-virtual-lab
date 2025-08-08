extends InteractableArea
var interactor: Node2D
var container_component: ContainerComponent

func get_interactions() -> Array[InteractInfo]:
	var info: InteractInfo
	interactor = Interaction.active_drag_component.body

	if interactor is Pipe and interactor.has_tip:
		info = InteractInfo.new(InteractInfo.Kind.PRIMARY, "Dispose tip")

	elif interactor.is_in_group("Emptyable"): 
		container_component = get_container_compoenent(interactor)
		
		if container_component and container_component.substances:
			info = InteractInfo.new(InteractInfo.Kind.PRIMARY, "Remove Contents")
	
	if info:
		return [info]
		
	return []
	
func start_interact(_kind: InteractInfo.Kind) -> void:
	if interactor is Pipe:
		interactor.has_tip = false
		
	elif container_component:
		container_component.substances.clear() # Discards all substances/contents
	
			
## Gets the container variable of the interactor 
func get_container_compoenent(interactor: LabBody) -> ContainerComponent:
	var container: Array[Node] = interactor.find_children("", "ContainerComponent", false)
	if container:
		return container.front()
	
	return null
