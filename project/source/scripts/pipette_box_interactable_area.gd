extends InteractableArea

var _info: InteractInfo = InteractInfo.new(InteractInfo.Kind.PRIMARY, "Add Tip")
var _disallowed_info: InteractInfo = InteractInfo.new(InteractInfo.Kind.PRIMARY, "Add Tip (Pipette already has a tip)", false)

func get_interactions() -> Array[InteractInfo]:
	if Interaction.held_body is Pipe:
		if Interaction.held_body.has_tip: return [_disallowed_info]
		else: return [_info]

	return []

func start_interact(_kind: InteractInfo.Kind) -> void:
	var pipette: Pipe = Interaction.held_body
	pipette.has_tip = true
	pipette.is_tip_contaminated = false
