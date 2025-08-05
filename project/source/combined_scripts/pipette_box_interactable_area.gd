extends InteractableArea

var info: InteractInfo = InteractInfo.new(InteractInfo.Kind.PRIMARY, "Add Tip")
var pipette: LabBody = null

func get_interactions() -> Array[InteractInfo]:
	if Interaction.active_drag_component.body is Pipe:
		return [info]
	
	return []
	
func start_interact(_kind: InteractInfo.Kind) -> void:
	pipette = Interaction.active_drag_component.body 
	if pipette.has_tip:
		print("Pipette already has a tip!")
		return
	
	pipette.has_tip = true
	pipette.is_tip_contaminated = false
