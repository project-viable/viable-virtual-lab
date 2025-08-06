extends InteractableArea
var info: InteractInfo
var interactor: Node2D
var container_component: ContainerComponent

func get_interactions() -> Array[InteractInfo]:
	interactor = Interaction.active_drag_component.body
	
	if interactor is Pipe:
		info = InteractInfo.new(InteractInfo.Kind.PRIMARY, "Dispose tip")

	else: 
		info = InteractInfo.new(InteractInfo.Kind.PRIMARY, "Dispose Contents") # Discards substances
	
	if info:
		return [info]
		
	return []
	
func start_interact(_kind: InteractInfo.Kind) -> void:
	if interactor is Pipe:
		interactor.has_tip = false
		
	else:
		container_component = get_container(interactor)
		container_component.substances.clear()
		
		
## Sets the container variable 
func get_container(interactor: LabBody) -> ContainerComponent:
	var containers: Array[Node] = interactor.find_children("", "ContainerComponent")
	if containers:
		return containers[0]
		
	return null
