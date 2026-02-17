class_name GelTray
extends LabBody


## Rate non-gel TAE is spilled, in mL/s.
const TAE_SPILL_RATE: float = 20


## Voltage, where positive is down the gel.
@export_custom(PROPERTY_HINT_NONE, "suffix:V") var voltage: float = 0.0
@export var gel_state: GelState
@export var has_wells: bool = false
@export var correct_wire_placement: bool
@export var gel_analysis_time: float

@export_group("Initial Run")
## Automatically run the gel when this node is ready. This can be used for debugging.
@export_custom(PROPERTY_HINT_GROUP_ENABLE, "") var enable_initial_run: bool = false
@export var initial_run_default_voltage: float = 120.0
## Specify different voltages for each well in the initial run.
@export var initial_run_well_voltages: Array[float] = []
@export var initial_run_default_concentration: float = 1 / 100.0
## Agarose concentrations for each well in the initial run.
@export var initial_run_well_concentrations: Array[float] = []
@export var initial_run_default_time: float = 20 * 60
## Run times for each well in the initial run.
@export var initial_run_well_times: Array[float] = []


var comb_placed: bool = false
var check_gel_concentration:bool = false
var suspended_agarose_concentration: float
var is_sealed: bool = false
# Used to allow TAE to leak from the tray into the rig.
var rig_container: ContainerComponent = null

class GelConcentrationData:
	var total_volume: float
	var mean: float
	var standard_deviation: float

func calculate_std(mean: float) -> float:
	var sum_of_squares: float = 0.0
	for s:Substance in $ContainerComponent.substances:
			if s is TAEBufferSubstance:
				sum_of_squares += pow((s.agarose_concentration * 100) - mean, 2)
	var variance: float = sum_of_squares / 5.0
	return  sqrt(variance)


func get_gel_concentration() -> float:
	var gel_data: GelConcentrationData = GelConcentrationData.new()
	if $ContainerComponent.substances != null:
		for s:Substance in $ContainerComponent.substances:
			if s is TAEBufferSubstance:
				gel_data.total_volume+= (s.agarose_concentration * 100)
				suspended_agarose_concentration = s.suspended_agarose_concentration
		gel_data.mean = gel_data.total_volume/5.0
		gel_data.standard_deviation = calculate_std(gel_data.mean)
	return gel_data.standard_deviation

func _ready() -> void:
	super()
	_set_subscene_has_wells(has_wells or enable_initial_run)

	var initial_voltage: float = voltage

	if enable_initial_run:
		for i in 5:
			var v := _get_or_default(initial_run_well_voltages, i, initial_run_default_voltage)
			var c := _get_or_default(initial_run_well_concentrations, i, initial_run_default_concentration)
			var t := _get_or_default(initial_run_well_times, i, initial_run_default_time)
			get_well(i + 1).send_event(RunGelSubstanceEvent.new(v, c, t))

	voltage = initial_voltage

func _physics_process(delta: float) -> void:
	super(delta)

	if not is_sealed:
		for s: Substance in $ContainerComponent.substances:
			if s is TAEBufferSubstance and not s.is_solid_gel():
				var taken := s.take_volume(TAE_SPILL_RATE * delta)
				if rig_container:
					rig_container.add(taken)

	if voltage > 0:
		gel_state.voltage = voltage
		gel_state.voltage_run_time += (delta * LabTime.time_scale)/60
		var voltage_data: String = str(gel_state.voltage, " volts ran through the gel")
		Game.report_log.update_event(voltage_data, "gel_voltage")
		Game.report_log.update_total(gel_state.voltage_run_time, "total_voltage_run_time")
		var voltage_time_data: String = str(gel_state.voltage, " volts run for ", gel_state.voltage_run_time," minutes")
		Game.report_log.update_event(voltage_time_data, "voltage_run_time")

		for i in 5:
			## Use 1% concentration by default for now.
			get_well(i + 1).send_event(RunGelSubstanceEvent.new(voltage, 1 / 100.0, delta * LabTime.time_scale))

func _process(_delta: float) -> void:
	Game.debug_overlay.update("gel voltage", str(voltage))
	Game.debug_overlay.update("gel comb attached", str($AttachmentInteractableArea.contained_object != null))


func num_wells() -> int: return 5

## Wells are numbered 1 to 5.
func get_well(i: int) -> ContainerComponent:
	return get_node_or_null("Subscene/Well%s" % [i])

func set_gel_state() -> void:
	if (LabTime.time_after_midnight - gel_analysis_time)/60.0 <= 5.0:
		gel_state.gel_analysis_asap = true
	var gel_analysis_time_data: String = str("It took ", gel_analysis_time/60, " minutes for gel to be analyzed in imager")
	Game.report_log.update_event(gel_analysis_time_data, "time_until_gel_analysis")
	gel_state.gel_concentration = get_gel_concentration()
	var concentration_data: String = str("The gel's concentration is ", gel_state.gel_concentration, "%")
	Game.report_log.update_event(concentration_data, "gel_concentration")
	if check_gel_concentration == false:
		if suspended_agarose_concentration <=0.0:
			gel_state.correct_gel_mixing = true
			Game.report_log.update_event("Gel is mixed thoroughly", "gel_mixed")
		else:
			gel_state.correct_gel_mixing = false
			Game.report_log.update_event("Gel is not thoroughly mixed ", "gel_mixed")
		check_gel_concentration = true

	for i in 5:
		if get_well(i + 1).substances != null:
			for s in get_well(i + 1).substances:
				if s is TAEBufferSubstance:
					gel_state.gel_concentration = s.agarose_concentration * 100
					if s.temperature <= 60.0 and s.temperature >= 50.0:
						gel_state.correct_gel_temperature = true
					else:
						gel_state.correct_gel_temperature = false
				gel_state.well_capacities[i] = s.get_volume()
				Game.report_log.append_to_array(str(gel_state.well_capacities[i]), "gel_well_capacities")
				break
		else:
			continue
	var well_max_data: String = str("The maximum each well can hold is ", gel_state.well_max_capacity, " mL")
	Game.report_log.update_event(well_max_data,"well_max_capacity")

func get_gel_state() -> GelState:
	return gel_state

# Comb inserted.
func _on_attachment_interactable_area_object_placed(_b: LabBody) -> void:
	comb_placed = true
	Game.report_log.update_event("The gel comb has been placed properly", "correct_comb_placement")

# Comb removed.
func _on_attachment_interactable_area_object_removed(_b: LabBody) -> void:
	var s: Substance = $SubstanceDisplayPolygon.get_substance_at_global($GelTopRef.global_position)
	_set_subscene_has_wells(s is TAEBufferSubstance and s.is_solid_gel())

func _set_subscene_has_wells(new_has_wells: bool) -> void:
	has_wells = new_has_wells

	%SubsceneWellSprites.visible = has_wells
	%WellBlockCollision.set_deferred("disabled", has_wells)

	# Simply clear all of the wells if they're re-disabled.
	if not has_wells:
		for i in num_wells():
			get_well(i + 1).substances.clear()

func _get_or_default(arr: Array[float], index: int, default: float) -> float:
	if index < arr.size(): return arr[index]
	else: return default


## Event sent by this gel repeatedly while it's running.
class RunGelSubstanceEvent extends Substance.Event:
	## Voltage of the current.
	var voltage: float
	## Concentration of the gel (in g/mL).
	var gel_concentration: float
	## Amount of time run, in seconds of lab time.
	var duration: float


	func _init(p_voltage: float, p_gel_concentration: float, p_duration: float) -> void:
		voltage = p_voltage
		gel_concentration = p_gel_concentration
		duration = p_duration
