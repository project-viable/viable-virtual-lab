extends Node2D


# Usually, we would prefer to have the interaction input handling in the [Interaction] singleton,
# but the [SubViewport] surrounding the main scene absorbs input and causes the input handling order
# to be weird. So instead, we handle it here.
func _unhandled_input(e: InputEvent) -> void:
	var kind := InteractInfo.Kind.PRIMARY
	var found_kind := false
	for k: InteractInfo.Kind in InteractInfo.Kind.values():
		if e.is_action(InteractInfo.kind_to_action(k)):
			kind = k
			found_kind = true
			break

	if not found_kind: return

	var state: Interaction.InteractState = Interaction.interactions.get(kind)
	if not state or not state.info: return

	if e.is_pressed(): state.start_interact()
	elif e.is_released(): state.stop_interact()

	get_viewport().set_input_as_handled()
