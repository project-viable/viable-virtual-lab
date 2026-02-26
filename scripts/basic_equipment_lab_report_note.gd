class_name BasicEquipmentLabReportNote
extends LabReportNote


## Containers that have been contaminated by reused pipette tips.
var contaminated_containers: Array[ContainerComponent] = []
## Set to [code]true[/code] if any substance was added to a container on the scale without taring
## it first.
var measured_without_taring: bool = false


func add_to_label(label: RichTextLabel) -> void:
	var num_contaminated_containers := contaminated_containers.size()

	# Heading.
	label.push_font_size(24)
	label.add_text("Equipment mistakes")
	label.pop()
	label.newline()
	label.newline()

	if num_contaminated_containers <= 0 and not measured_without_taring:
		label.add_text("None")
		return

	label.push_list(1, RichTextLabel.LIST_DOTS, false)
	if num_contaminated_containers == 1:
		label.add_text("Contaminated a container by reusing a pipette tip.")
	elif num_contaminated_containers > 1:
		label.add_text("Contaminated %s containers by reusing pipette tips." % num_contaminated_containers)
	if measured_without_taring:
		label.add_text("Didn't tare the scale before measuring.")
	label.pop()
