extends InteractableArea


var interactor: Node2D
var container_component: ContainerComponent

var _interact_canvas_group: SelectableCanvasGroup


func _ready() -> void:
	super()
	_interact_canvas_group = Util.try_get_best_selectable_canvas_group(self)

func get_interactions() -> Array[InteractInfo]:
	var info: InteractInfo
	interactor = Interaction.held_body

	if interactor is Pipette and interactor.has_tip:
		info = InteractInfo.new(InteractInfo.Kind.PRIMARY, "Dispose tip")

	elif interactor.is_in_group("Emptyable"):
		container_component = get_container_compoenent(interactor)

		if container_component and container_component.substances:
			info = InteractInfo.new(InteractInfo.Kind.PRIMARY, "Remove Contents")

	if info:
		return [info]

	return []

func start_interact(_kind: InteractInfo.Kind) -> void:
	if interactor is Pipette:
		interactor.has_tip = false

	elif container_component:
		container_component.substances.clear() # Discards all substances/contents

func start_targeting(_kind: InteractInfo.Kind) -> void:
	if _interact_canvas_group: _interact_canvas_group.is_outlined = true
func stop_targeting(_kind: InteractInfo.Kind) -> void:
	if _interact_canvas_group: _interact_canvas_group.is_outlined = false


## Gets the container variable of the interactor
func get_container_compoenent(interactor: LabBody) -> ContainerComponent:
	var container: Array[Node] = interactor.find_children("", "ContainerComponent", false)
	if container:
		return container.front()

	return null
