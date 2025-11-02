extends UseComponent
class_name PourUseComponent
@export var container_component: ContainerComponent 
@export var amount_to_pour: float # In ml

var container_component_to_receive: ContainerComponent

func get_interactions(area: InteractableArea) -> Array[InteractInfo]: 
	var info: InteractInfo

	# Must have a container_component reference
	if not container_component:
		return []
	
	if area and area is PourInteractableArea:
		container_component_to_receive = area.container_component
		if container_component_to_receive and container_component.substances:
			info = InteractInfo.new(InteractInfo.Kind.SECONDARY, "Pour")
			
		elif container_component_to_receive and not container_component.substances:
			info = InteractInfo.new(InteractInfo.Kind.SECONDARY, "Pour (Container is Empty)", false)
	 
	if info:
		return [info]
		
	return []

func start_use(_area: InteractableArea, _kind: InteractInfo.Kind) -> void: 
	var amount: float = amount_to_pour
	# Pours a calculated amount to the max if the amount to pour exceeds the max volume of the container
	if container_component_to_receive.get_total_volume() + amount > container_component_to_receive.container_volume:
		amount = container_component_to_receive.container_volume - container_component_to_receive.get_total_volume()
		
		# Ensure the amount to pour can't be negative nor exceed the max volume of a container
		amount = clamp(amount, 0, container_component.container_volume)
		
	print("Pouring %s ml" % [amount])
	var substances := container_component.take_volume(amount)
	container_component_to_receive.add_array(substances)
