extends InteractableArea

var info: InteractInfo = InteractInfo.new(InteractInfo.Kind.PRIMARY, "Add Tip")
var pipette: LabBody = null

func get_interactions() -> Array[InteractInfo]:
	if Interaction.active_drag_component.body is Pipe:
		return [info]
	
	return []
	
func start_interact(_kind: InteractInfo.Kind) -> void:
	pipette = Interaction.active_drag_component.body 
	pipette.has_tip = true
