class_name GelLogReport
extends Node

@onready var rich_text_label: RichTextLabel = get_node("%ReportText")

var report_data := {
	"scooped_agarose_powder": "0.0 mL of agarose powder add to ", 
	"poured_tae_in_gel": "0.0 mL of TAE Buffer is in the gel", 
	"microwave_time": "___ heated for ___ minutes", 
	"gel_heated_temperature": "___ heated to ___ degrees Celsius",
	"gel_concentration": "The gel's concentration is 0%", 
	"gel_mixed": "Gel is not thoroughly mixed ",
	"poured_tae_in_rig": "0.0 mL of TAE Buffer poured into GelRig", 
	"correct_comb_placement": "The gel comb has not been placed properly",
	"gel_well_capacities": [], 
	"dna_fragment_sizes": [],#
	"well_max_capacity": "The maximum each well can hold is 0 mL", 
	"electrode_correct_placement": "Electrodes have not been correctly plugged into the power supply and gel rig",
	"gel_voltage": "0 volts ran through the gel", 
	"voltage_run_time": "0 volts run for 0 minutes",
	"time_until_gel_analysis": "It took 0 minutes for gel to be analyzed in imager", 
	"gel_band_per_dna_sample": "",
	"total_agarose_powder": 0.0,
	"total_tae_in_gel": 0.0, 
	"total_poured_tae_in_rig": 0.0, 
	"total_microwave_time": 0.0, 
	"total_voltage_run_time": 0.0,
	"final_results": ""
}

func _ready() -> void:
	rich_text_label.bbcode_enabled = true
	
## Function to update event values in the report log dictionary
func update_event(data: String, event_name: String) -> void:
	report_data[event_name] = data

func append_amount(data: String, event_name: String) -> void:
	report_data[event_name] += data

## Function to update total values for things like time, weights, or volumes incrementally
func update_total(data:float, total_name: String) -> void:
	report_data[total_name] += data
	
## Function to overwrite total values for things like time, weights, or volumes 
func new_total(data:float, total_name: String) -> void:
	report_data[total_name] = data

## Function to save recorded user events to a log file in the form of a JSON Object
func save_game_data() -> void:
		var filename: String = "save_report.txt"
		if Engine.has_singleton("JavaScriptBridge"):
			JavaScriptBridge.download_buffer(rich_text_label.get_parsed_text().to_utf8_buffer(), filename,"text/plain")
		else:
			Game.debug_overlay.update("result", "JavaScriptBridge not available")

## Function to read the final report data from the JSON file to be formatted in a readable document
# report will be formatted here with rich text labels to put in report"
func load_report_data() -> void:
	rich_text_label.append_text("[center][b][font_size=36]Final Report[/font_size][/b][/center]\n")
	
	rich_text_label.append_text("\n[center][b][font_size=24]Preparing The Gel[/font_size][/b][/center]\n")
	rich_text_label.append_text("\n" + report_data["scooped_agarose_powder"])
	rich_text_label.append_text("\n" + report_data["poured_tae_in_gel"])
	rich_text_label.append_text("\n" + report_data["microwave_time"])
	rich_text_label.append_text("\n" + report_data["gel_heated_temperature"])
	rich_text_label.append_text("\n" + report_data["gel_mixed"])
	
	rich_text_label.append_text("\n\n[center][b][font_size=24]Gel Electrophoresis Process[/font_size][/b][/center]\n")
	rich_text_label.append_text("\n" + report_data["poured_tae_in_rig"])
	rich_text_label.append_text("\n" + report_data["correct_comb_placement"])
	rich_text_label.append_text("\n" + report_data["electrode_correct_placement"])
	rich_text_label.append_text("\n" + report_data["gel_voltage"])
	rich_text_label.append_text("\n" + report_data["voltage_run_time"])
	rich_text_label.append_text("\n" + report_data["time_until_gel_analysis"])
	
	rich_text_label.append_text("\n\n[center][b][font_size=24]Gel Analysis[/font_size][/b][/center]\n")
	rich_text_label.append_text("\n" + report_data["gel_concentration"])
	rich_text_label.append_text("\n" + report_data["well_max_capacity"])
	var well_cap_string: String = ("\nThe used wells hold " + ", ".join(report_data["gel_well_capacities"]) + " mLs of dna samples, respectively")
	rich_text_label.append_text(well_cap_string)
	var dna_frag_string: String = ("\nThe dna samples had fragment sizes of " +  ", ".join(report_data["dna_fragment_sizes"]))
	rich_text_label.append_text(dna_frag_string)
	
	rich_text_label.append_text("\n\n[center][b][font_size=24]Final results[/font_size][/b][/center]\n")
	rich_text_label.append_text("\n" + report_data["final_results"])
	
func _on_button_pressed() -> void:
	save_game_data()
