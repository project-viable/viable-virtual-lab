class_name GelMold
extends LabBody


## Voltage, where positive is down the gel.
@export var voltage: float = 0.0
@export var gel_state: GelState
var gel_container: ContainerComponent = get_node_or_null("ContainerComponent")
var power_supply_scene: PackedScene =  preload("res://scenes/power_supply.tscn")

class GelConcentrationData:
	var total_volume: float
	var mean: float
	var standard_deviation: float

func calculate_std(mean: float) -> float:
	var sum_of_squares: float = 0.0
	for s in gel_container.substances:
		if s is TAEBufferSubstance:
			sum_of_squares += pow((s.agarose_concentration * 100) - mean, 2)
	var variance: float = sum_of_squares / 5.0
	return  sqrt(variance)
	

func get_gel_concentration() -> float:
	var gel_data: GelConcentrationData = GelConcentrationData.new()
	if gel_container.substances != null:
		for concentration in gel_container.substances:
			for s in gel_container.substances:
				if s is TAEBufferSubstance:
					gel_data.total_volume+= (s.agarose_concentration * 100)
		gel_data.mean = gel_data.total_volume/5.0
		gel_data.standard_deviation = gel_data.calculate_std(gel_data.mean)
	return gel_data.standard_deviation
		

func _physics_process(delta: float) -> void:
	super(delta)
	for i in 5:
		for s in get_well(i + 1).substances:
			if s is DNASolutionSubstance:
				s.run_voltage(voltage, delta * LabTime.time_scale, 1.0)

	if Engine.get_physics_frames() % 60 == 0:
		print("Gel voltage: %s" % [voltage])

func num_wells() -> int: return 5

## Wells are numbered 1 to 5.
func get_well(i: int) -> ContainerComponent:
	return get_node_or_null("Subscene/Well%s" % [i])

func set_gel_state() -> void:
	gel_state.voltage = int(voltage)
	gel_state.gel_concentration = get_gel_concentration()
	if gel_state.gel_concentration < 0.1:
		gel_state.correct_gel_mixing = true
	else:
		gel_state.correct_gel_mixing = false
	var power_supply: PowerSupply = power_supply_scene.get_node_or_null("PowerSupply")
	gel_state.voltage_run_time = power_supply.initial_time/60
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
		else:
			continue
	
	
		
func get_gel_state() -> GelState:
	return gel_state
	
