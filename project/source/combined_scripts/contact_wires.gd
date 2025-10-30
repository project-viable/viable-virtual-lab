extends Node2D
@export var power_supply: PowerSupply

func _process(_delta: float) -> void:
	# Make sure to draw on top of the wire ends.
	z_index = 0
	for child in get_children():
		for wire in child.get_children():
			if wire is CanvasItem:
				z_index = max(z_index, wire.z_index)

	z_index += 1

	if Interaction.held_body and Interaction.held_body.find_children("", "WireConnectableComponent"):
		queue_redraw()

func _ready() -> void:
	for contact_wire: Wire in get_tree().get_nodes_in_group("contact_wire"):
		contact_wire.connect("moved", queue_redraw)

	# Each contact wire should know about its other end
	for child: Node2D in get_children():
		var wires: Array[Node] = child.get_children()
		wires[0].other_end = wires[1]
		wires[1].other_end = wires[0]

func _draw() -> void:
	# Draw a black line between each pair of wire contact
	for child: Node2D in get_children():
		var wires: Array[Node] = child.get_children()
		draw_line(wires[0].position, wires[1].position, Color.BLACK)
	queue_redraw()
