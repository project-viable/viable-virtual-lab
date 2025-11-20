extends LabBody


func _physics_process(delta: float) -> void:
	super(delta)
	var gel := $MoldAttachment.contained_object as GelMold
	if gel:
		gel.voltage = $WireConnectableComponent.voltage if _is_filled() else 0.0

# True if the box is filled enough with buffer to conduct and stuff.
func _is_filled() -> bool:
	return $SubstanceDisplayPolygon.get_substance_at_global($FillRef.global_position) != null

func _on_mold_attachment_object_placed(body: LabBody) -> void:
	# Flood and clear the wells if already full.
	if body is GelMold and _is_filled():
		for i: int in body.num_wells():
			body.get_well(i + 1).substances.clear()

func _on_mold_attachment_object_removed(body: LabBody) -> void:
	if body is GelMold: body.voltage = 0
