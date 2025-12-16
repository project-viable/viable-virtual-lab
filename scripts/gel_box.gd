extends LabBody

var gel_in_rig: bool = true
@export var gel_analysis_time: float

func _physics_process(delta: float) -> void:
	super(delta)
	var gel := $MoldAttachment.contained_object as GelMold
	if gel:
		gel.voltage = $WireConnectableComponent.voltage if _is_filled() else 0.0
		if (gel.gel_state.gel_analysis_time/60.0) > 5.0:
			gel.gel_state.gel_analysis_asap = false
	if gel_in_rig == false:
		gel_analysis_time = delta * LabTime.time_scale

# True if the box is filled enough with buffer to conduct and stuff.
func _is_filled() -> bool:
	if $SubstanceDisplayPolygon.get_substance_at_global($FillRef.global_position) != null:
		Game.report_log.update_total($ContainerComponent.get_total_volume(),"total_poured_tae_in_rig")
		var tae_pour_data: String = str(Game.report_log.report_data["total_poured_tae_in_rig"], " mL of TAE Buffer poured into GelRig")
		Game.report_log.update_event(tae_pour_data, "poured_tae_in_rig")
		return true
	else:
		return false

func _on_mold_attachment_object_placed(body: LabBody) -> void:
	# Flood and clear the wells if already full.
	if body is GelMold and _is_filled():
		for i: int in body.num_wells():
			body.get_well(i + 1).substances.clear()

func _on_mold_attachment_object_removed(body: LabBody) -> void:
	if body is GelMold: 
		body.voltage = 0
		gel_in_rig = false
