extends LabBody


# True if the box is filled enough with buffer to conduct and stuff.
func _is_filled() -> bool:
	return $SubstanceDisplayPolygon.global_fluid_top_y_coord < $FillRef.global_position.y

func _on_mold_attachment_object_placed(body: LabBody) -> void:
	# Flood and clear the wells if already full.
	if body is GelMold and _is_filled():
		for i: int in body.num_wells():
			body.get_well(i + 1).substances.clear()
