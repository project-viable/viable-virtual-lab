extends Node2D
@export var power_supply: PowerSupply

func _process(_delta: float) -> void:
	if Interaction.held_body and Interaction.held_body.find_children("", "WireConnectableComponent"):
		_on_moved()

func _ready() -> void:
	for contact_wire: Wire in get_tree().get_nodes_in_group("contact_wire"):
		contact_wire.connect("moved", _on_moved)
	
	# Each contact wire should know about its other end
	for child: Node2D in get_children():
		var wires: Array[Node] = child.get_children()
		wires[0].other_end = wires[1]
		wires[1].other_end = wires[0]

func _draw() -> void:
	# Draw a black line between each pair of wire contact
	for child: Node2D in get_children():
		var wires: Array[Node] = child.get_children()
		draw_line(wires[0].position, wires[1].position, "black")

## Keep the wires on the top-most level whenever it moves. This accounts for when its moving 
## While connected to the Power Supply
func _on_moved() -> void:
	# Check if the wires are already on the top-most level, if not remove and then re-add
	if not self.get_index() == get_parent().get_child_count() - 1:
		get_parent().call_deferred(&"remove_child", self)
		get_parent().call_deferred(&"add_child", self)
		
	queue_redraw()
