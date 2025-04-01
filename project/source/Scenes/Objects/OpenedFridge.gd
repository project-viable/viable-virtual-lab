extends StaticBody2D

var is_open: bool = true
signal on_click(is_open: bool)

func _ready() -> void:
	# When the fridge is opened, the slide collision shape takes priority
	# Otherwise, clicking on slides would close the fridge
	# TODO: Should be able to click individual Slides and drag and drop them into Microscope. Right now just testing things out
	get_viewport().set_physics_object_picking_sort(true)
	get_viewport().set_physics_object_picking_first_only(true)

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and is_open:
		is_open = false
		on_click.emit(is_open)
		
