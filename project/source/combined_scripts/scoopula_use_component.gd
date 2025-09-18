extends UseComponent

@export var container: ContainerComponent
var vol_to_take: float = 0.1
var vol_to_dispense: float = 0.1
var area: InteractableArea

func get_interactions(area: InteractableArea) -> Array[InteractInfo]:
	## If the scoopula is empty, return the interaction "scoop"
	if area is ScoopInteractableArea and container.substances.is_empty(): 
		return [InteractInfo.new(InteractInfo.Kind.PRIMARY, "Scoop 0.1 mL")]
	elif area is ScoopInteractableArea and !container.substances.is_empty(): 
		return [InteractInfo.new(InteractInfo.Kind.SECONDARY, "Dispense 0.1 mL")]
	else: return []

func start_use(_area: InteractableArea, _kind: InteractInfo.Kind) -> void:
	area = _area
	if not (area is ScoopInteractableArea):
		return
	match _kind:
		0:
			## If the container being interacted with isn't empty but the amount the user wants to scoop is greater than the
			## amount in said container or how much the scoopula can hold, the user will be notified that they can't do that.
			## Otherwise, the user can scoop like normal
			if not area.container.substances.is_empty():
				if vol_to_take > area.container.get_total_volume() or vol_to_take > container.get_volume():
					print("too many ml added to scoopula")
				else:
					### Add contents to scoopula and update containers's substance volume
					container.add(area.container.take_volume(vol_to_take))
					print("My scoopula after scooping has volume of: ", container.get_total_volume())
					
					get_parent().find_child("FillSprite").visible = true
			
			else:
				print("container is empty. There is nothing to scoop")	
		1:
			if container.substances.is_empty():
				print("scoopula is empty")
			else:
				## As long as the scoopula isn't empty and the container isn't full, the user can dispense substances from it
				## Add contents to receiving container if it isn't full
				## Reset scoopula
				if not area.container.substances.is_empty():
					area.container.add(container.take_volume(container.get_volume()-area.container.get_total_volume()))
				else:
					area.container.add(container.take_volume(container.get_volume()))
				container.substances.clear()
				get_parent().find_child("FillSprite").visible = false
				#print(area.container, " after being dumped into has volume of: ", area.container.get_total_volume())
		
			
			print("scoopula empty?: ", container.substances.is_empty())
