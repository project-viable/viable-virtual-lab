extends UseComponent

@export var container: ContainerComponent
var vol_to_take: float = 0.1
var vol_to_dispense: float = 0.1

func get_interactions(area: InteractableArea) -> Array[InteractInfo]:
	## If the scoopula is empty, return the interaction "scoop"
	if not (area is ContainerInteractableArea) or not area.is_in_group(&"container:scoop"):
		return []

	if container.substances.is_empty():
		return [
			InteractInfo.new(InteractInfo.Kind.PRIMARY, "Scoop 0.1 mL"),
			InteractInfo.new(InteractInfo.Kind.SECONDARY, "Scoopula is already full", false),
		]
	else:
		return [
			InteractInfo.new(InteractInfo.Kind.PRIMARY, "Scoopula is empty", false),
			InteractInfo.new(InteractInfo.Kind.SECONDARY, "Dispense 0.1 mL"),
		]

func start_use(area: InteractableArea, kind: InteractInfo.Kind) -> void:
	if not (area is ContainerInteractableArea): return

	match kind:
		InteractInfo.Kind.PRIMARY:
			container.add_array(area.container_component.take_volume(vol_to_take))
			get_parent().find_child("FillSprite").visible = true

		InteractInfo.Kind.SECONDARY:
			area.container_component.add_array(container.take_volume(vol_to_dispense))
			get_parent().find_child("FillSprite").visible = false
