class_name ElectricalContact
extends LabBody


@export var other_end: ElectricalContact = null


var connected_terminal: ElectricalTerminal = null


func _ready() -> void:
	super()
	if other_end: other_end.other_end = self

func _draw() -> void:
	# Make sure only one of the two contacts does the drawing.
	if other_end and get_instance_id() < other_end.get_instance_id():
		draw_line(global_position, other_end.global_position, Color.BLACK, 2.0, true)
