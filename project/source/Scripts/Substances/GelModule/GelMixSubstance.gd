extends Substance

# This represents the gel mixture, and thus responds to heating and cooling.

var gel_ratio: float = 0.0 # gel ratio does not change when heated, only viscosity does
var total_heat_time: float = 0 #This is a variable used if the substance should be heatable
	# It can be changed as needed for specific modules, and is only used if the 
	# container is a member of the group "Heatable"
var viscosity: float = 0
var cooled: bool = false

func _init() -> void:
	var properties := {
		'density': 1.1
	}
	
	# call the superclass init
	init_created(properties)

func init_mixed(parent_substances: Array[Substance]) -> void:
	# determine the gel ratio from the parent masses
	var agar_props: Dictionary = parent_substances[0].get_properties() if parent_substances[0].name == "AgarPowderSubstance" \
		else parent_substances[1].get_properties()
	var binder_props: Dictionary= parent_substances[0].get_properties() if parent_substances[1].name == "AgarPowderSubstance" \
		else parent_substances[1].get_properties()
	gel_ratio = agar_props['volume'] / binder_props['volume']
	print('Got gel ratio '+str(gel_ratio))
	
	volume = agar_props['volume'] + binder_props['volume']
	
	var substances: Dictionary = {
		'substances': {
			'agar': agar_props,
			'binder': binder_props
		}
	}
	report_action([self], 'mixSubstance', substances)

func init_created(properties: Dictionary) -> void:
	if(properties.has('gel ratio')):
		gel_ratio = properties['gel ratio']
	if(properties.has('viscosity')):
		gel_ratio = properties['viscosity']
	
	# blend the parent colors together to get the resulting mix
	var agar_color := Color('#ccffdd')
	agar_color.a = gel_ratio
	properties['color'] = Color('#00cc66').blend(agar_color)
	
	# call the superclass init
	super.init_created(properties)

func heat(heat_time: float) -> void:
	total_heat_time += heat_time
	
	# Using 1 for ideal viscosity for use in running the gel, heating variables 
	# use the error formula to alter viscosity based on effects of over/
	# underheating and of over/under content volumes
	
	# 40 is currently a placeholder value for the ideal heating time for the lab
	viscosity = 1 + ((total_heat_time - 40)/40)
	print("Gel viscosity after heating: " + str(viscosity))
	#get_current_module_scene().HeatingChecker([total_heat_time])

func chill(chill_time: float) -> void:
	if total_heat_time > 30 and total_heat_time < 70:
		cooled = true
		total_heat_time -= chill_time
		
		self.remove_from_group("Liquid Substance")
		self.add_to_group("Solid Substance")
	else:
		print("Gel has not been heated enough to be cooled")
	
func determine_accuracy(ideal: float, actual: float) -> float:
	return 1 + (abs(actual) - ideal) / float(ideal)

func run_current(voltage: float, time: float) -> void:
	# The ideal scenario is 120V and around 20 minutes
	# So, total_run_time should equal approximately 20 at the end in the correct scenario
	
	# These time modifiers below will make the total_run_time increase at a different rate based on how
	# the current and voltage differ from their ideal values
	
	# Multiply the time variable passed from the CurrentSource by voltage modifier
	# These values are subject to change and are thus placeholders for now
	var voltage_modifier := determine_accuracy(120, voltage)
	
	time = time * voltage_modifier
	total_run_time += (time * sign(voltage))
	
	if total_run_time > 21:
		LabLog.error("Total current run time has exceeded 20 minutes")

func get_properties() -> Dictionary:
	return {
		"color": color,
		"volume": volume,
		"gel ratio": gel_ratio,
		"viscosity": viscosity
	}
