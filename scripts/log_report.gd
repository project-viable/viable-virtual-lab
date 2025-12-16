class_name GelLogReport
extends Node

var report_data := {
	"scooped_agarose_powder": "", #
	"poured_tae_in_gel": "", #
	"microwave_time": "", #
	"gel_temperature": "",
	"gel_concentration": "", #
	"gel_mixed": "",#
	"poured_tae_in_rig": "", #
	"correct_comb_placement": "",#
	"pipetted_amount_per_well": "",
	"dna_fragment_sizes": [],
	"gel_well_capacities": [], #
	"well_max_capacity": "", #
	"electrode_correct_placement": "", #
	"gel_voltage": "", #
	"voltage_run_time": "",#
	"time_until_gel_analysis": "", #
	"gel_band_per_dna_sample": "",
	"total_agarose_powder": 0.0,#
	"total_tae_in_gel": 0.0, #
	"total_poured_tae_in_rig": 0.0, #
	"total_microwave_time": 0.0, #
	"total_voltage_run_time": 0.0#
}

## Function to update event values in the report log dictionary
func update_event(data: String, event_name: String) -> void:
	print(event_name)
	report_data[event_name] = data
	print(report_data[event_name])
	
func append_amount(data: String, event_name: String) -> void:
	print(event_name)
	report_data[event_name].append(data)

## Function to update total values for things like time, weights, or volumes
func update_total(data:float, total_name: String) -> void:
	report_data[total_name] += data

## Function to save recorded user events to a log file in the form of a JSON Object
func save_game_data(report_data: Dictionary, filename: String = "save_report.json") -> void:
		pass

## Function to read the final report data from the JSON file to be formatted in a readable document
# file path will be "res://save_report.json"
func load_report_data(file_path: String) -> Dictionary:
	return {}
