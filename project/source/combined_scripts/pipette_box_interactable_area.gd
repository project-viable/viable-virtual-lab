extends InteractableArea

var _info: InteractInfo = InteractInfo.new(InteractInfo.Kind.PRIMARY, "Add Tip")
var _disallowed_info: InteractInfo = InteractInfo.new(InteractInfo.Kind.PRIMARY, "(Tip is already attached)", false)

func get_interactions() -> Array[InteractInfo]:
	if Interaction.held_body is Pipe:
		if Interaction.held_body.has_tip: return [_disallowed_info]
		else: return [_info]

	return []

func start_interact(_kind: InteractInfo.Kind) -> void:
	var pipette: Pipe = Interaction.held_body
	if pipette.has_tip:
		print("Pipette already has a tip!")
		return
	
	pipette.has_tip = true
	pipette.is_tip_contaminated = false
