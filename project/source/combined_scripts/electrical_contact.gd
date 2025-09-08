@tool
class_name ElectricalContact
extends LabBody


@export var other_end: ElectricalContact = null


var connected_terminal: ElectricalTerminal = null


func _ready() -> void:
	super()
	if other_end: other_end.other_end = self

func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	# Make sure only one of the two contacts does the drawing.
	if other_end and get_instance_id() < other_end.get_instance_id():
		draw_line(Vector2.ZERO, to_local(other_end.global_position), Color.BLACK, 1.0, true)
