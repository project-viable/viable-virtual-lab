extends Node2D
@export var power_supply: PowerSupply

func _process(_delta: float) -> void:
	if Interaction.active_drag_component and Interaction.active_drag_component.body is PowerSupply:
		_on_moved()

func _ready() -> void:
	for contact_wire: Wire in get_children():
		contact_wire.connect("moved", _on_moved)
		
func _draw() -> void:
	draw_line($RedContactWire.position, $RedContactWire2.position, "black")
	draw_line($BlackContactWire.position, $BlackContactWire2.position, "black")

## Keep the wires on the top-most level whenever it moves. This accounts for when its moving 
## While connected to the Power Supply
func _on_moved() -> void:
	# Check if the wires are already on the top-most level, if not remove and then re-add
	if not self.get_index() == get_parent().get_child_count() - 1:
		get_parent().call_deferred(&"remove_child", self)
		get_parent().call_deferred(&"add_child", self)
		
	queue_redraw()
