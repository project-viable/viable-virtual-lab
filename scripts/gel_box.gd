extends LabBody

var gel_in_rig: bool = true
@export var gel_analysis_time: float

func _physics_process(delta: float) -> void:
	super(delta)
	
	$CircuitComponent.closed = _is_filled()
	
	var gel := $TrayAttachment.contained_object as GelTray
	if gel:
		# This should automatically be updated by the power supply to zero after setting `closed`.
		gel.voltage = $CircuitComponent.voltage
		if (gel.gel_state.gel_analysis_time/60.0) > 5.0:
			gel.gel_state.gel_analysis_asap = false
	if gel_in_rig == false:
		gel_analysis_time = delta * LabTime.time_scale

# True if the box is filled enough with buffer to conduct and stuff.
func _is_filled() -> bool:
	return $SubstanceDisplayPolygon.get_substance_at_global($FillRef.global_position) != null

func _on_mold_attachment_object_placed(body: LabBody) -> void:
	# Flood and clear the wells if already full.
	if body is GelTray:
		body.rig_container = $ContainerComponent
		if _is_filled():
			for i: int in body.num_wells():
				body.get_well(i + 1).substances.clear()

func _on_mold_attachment_object_removed(body: LabBody) -> void:
	if body is GelTray:
		body.voltage = 0
		gel_in_rig = false
		body.rig_container = null
