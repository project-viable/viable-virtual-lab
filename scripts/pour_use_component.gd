extends UseComponent
class_name PourUseComponent
@export var container_component: ContainerComponent
@export var amount_to_pour: float # In ml

var container_component_to_receive: ContainerComponent


func get_interactions(area: InteractableArea) -> Array[InteractInfo]:
	var results: Array[InteractInfo] = []

	# Must have a container_component reference
	if not container_component:
		return []

	if area and area is PourInteractableArea:
		container_component_to_receive = area.container_component
		if container_component_to_receive and container_component.substances:
			results.push_back(InteractInfo.new(InteractInfo.Kind.SECONDARY, "Pour"))
		elif container_component_to_receive and not container_component.substances:
			results.push_back(InteractInfo.new(InteractInfo.Kind.SECONDARY, "Pour (Container is Empty)", false))

	if results and not Game.main.get_camera_focus_owner():
		results.push_back(InteractInfo.new(InteractInfo.Kind.INSPECT, "Zoom in to pour"))

	return results

func start_use(area: InteractableArea, kind: InteractInfo.Kind) -> void:
	match kind:
		InteractInfo.Kind.SECONDARY:
			var amount: float = amount_to_pour
			# Pours a calculated amount to the max if the amount to pour exceeds the max volume of the container
			if container_component_to_receive.get_total_volume() + amount > container_component_to_receive.container_volume:
				amount = container_component_to_receive.container_volume - container_component_to_receive.get_total_volume()

				# Ensure the amount to pour can't be negative nor exceed the max volume of a container
				amount = clamp(amount, 0, container_component.container_volume)

			print("Pouring %s ml" % [amount])
			var substances := container_component.take_volume(amount)
			container_component_to_receive.add_array(substances)
		InteractInfo.Kind.INSPECT:
			var parent_body := get_parent() as CollisionObject2D
			var area_parent_body := area.get_parent() as CollisionObject2D
			if not parent_body or not area_parent_body: return
			Game.main.focus_camera_on_rect(Util.get_global_bounding_box(parent_body).merge(Util.get_global_bounding_box(area_parent_body)))
			Game.main.set_camera_focus_owner(self)
