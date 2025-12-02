extends UseComponent

@export var container: ContainerComponent
var vol_to_take: float = 0.1
var vol_to_dispense: float = 0.1

func get_interactions(area: InteractableArea) -> Array[InteractInfo]:
	## If the scoopula is empty, return the interaction "scoop"
	if not (area is ContainerInteractableArea) or not area.is_in_group(&"container:scoop"):
		return []

	if container.substances.is_empty(): 
		return [InteractInfo.new(InteractInfo.Kind.PRIMARY, "Scoop 0.1 mL")]
	else:
		return [InteractInfo.new(InteractInfo.Kind.SECONDARY, "Dispense 0.1 mL")]

func start_use(area: InteractableArea, kind: InteractInfo.Kind) -> void:
	if not (area is ContainerInteractableArea): return

	match kind:
		InteractInfo.Kind.PRIMARY:
			## If the container being interacted with isn't empty but the amount the user wants to scoop is greater than the
			## amount in said container or how much the scoopula can hold, the user will be notified that they can't do that.
			## Otherwise, the user can scoop like normal
			if not area.container_component.substances.is_empty():
				if vol_to_take > area.container_component.get_total_volume() or vol_to_take > container.container_volume:
					print("too many ml added to scoopula")
				else:
					### Add contents to scoopula and update containers's substance volume
					container.add_array(area.container_component.take_volume(vol_to_take))
					print("My scoopula after scooping has volume of: ", container.get_total_volume())
					
					get_parent().find_child("FillSprite").visible = true
			
			else:
				print("container is empty. There is nothing to scoop")	
		InteractInfo.Kind.SECONDARY:
			if container.substances.is_empty():
				print("scoopula is empty")
			else:
				## As long as the scoopula isn't empty and the container isn't full, the user can dispense substances from it
				## Add contents to receiving container if it isn't full
				## Reset scoopula
				if not area.container_component.substances.is_empty():
					area.container_component.add_array(container.take_volume(container.container_volume-area.container_component.get_total_volume()))
				else:
					area.container_component.add_array(container.take_volume(container.container_volume))
				container.substances.clear()
				get_parent().find_child("FillSprite").visible = false
		
			
