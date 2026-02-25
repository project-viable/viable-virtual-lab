class_name BasicEquipmentLabReportNote
extends LabReportNote


## Number of times a pipette tip was used reused.
@export var num_reused_pipette_tips: int = 0
## Set to [code]true[/code] if any substance was added to a container on the scale without taring
## it first.
@export var measured_without_taring: bool = false


func add_to_label(label: RichTextLabel) -> void:
	# Heading.
	label.push_font_size(24)
	label.add_text("Equipment mistakes")
	label.pop()

	if num_reused_pipette_tips <= 0 and not measured_without_taring:
		label.add_text("None")
		return

	label.push_list(1, RichTextLabel.LIST_DOTS, false)
	if num_reused_pipette_tips > 0:
		label.add_text("Reused %s pipette tips" % num_reused_pipette_tips)
	if measured_without_taring:
		label.add_text("Didn't tare the scale before measuring")
	label.pop()
