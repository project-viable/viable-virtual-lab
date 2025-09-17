extends UseComponent
class_name PourUseComponent
@export var container_component: ContainerComponent 
@export var amount_to_pour: float # In ml

var object_to_receive: LabBody
var container_component_to_receive: ContainerComponent

func get_interactions(_area: InteractableArea) -> Array[InteractInfo]: 
	var info: InteractInfo
	
	if _area and _area.get_parent() is LabBody:
		object_to_receive = _area.get_parent()
		var container_components: Array[Node] = object_to_receive.find_children("", "ContainerComponent")
		
		if container_components and container_component.substances:
			container_component_to_receive = container_components.front()
			info = InteractInfo.new(InteractInfo.Kind.SECONDARY, "Pour")
			
		elif container_components and not container_component.substances:
			info = InteractInfo.new(InteractInfo.Kind.SECONDARY, "Pour (Container is Empty)", false)
	 
	if info:
		return [info]
		
	return []

func start_use(_area: InteractableArea, _kind: InteractInfo.Kind) -> void: 
	var amount: float = amount_to_pour
	# Pours a calculated amount to the max if the amount to pour exceeds the max volume of the container
	if container_component_to_receive.get_total_volume() + amount > container_component_to_receive.max_volume:
		amount = container_component_to_receive.max_volume - container_component_to_receive.get_total_volume()
		
		# Ensure the amount to pour can't be negative nor exceed the max volume of a container
		amount = clamp(amount, 0, container_component.max_volume)
		
	print("Pouring %s ml" % [amount])
	var substance: SubstanceInstance = container_component.take_volume(amount)
	container_component_to_receive.add(substance)
