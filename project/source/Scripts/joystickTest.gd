extends Sprite2D

@onready var up_arrow: Area2D = $upArrow
@onready var down_arrow: Area2D = $downArrow
@onready var left_arrow: Area2D = $leftArrow
@onready var right_arrow: Area2D = $rightArrow
@onready var speed_button: Area2D = $panningSpeed

var fast_panning: bool = false

func _ready() -> void:
	up_arrow.connect("input_event", self._on_up_arrow_input_event)
	down_arrow.connect("input_event", self._on_down_arrow_input_event)
	left_arrow.connect("input_event", self._on_left_arrow_input_event)
	right_arrow.connect("input_event", self._on_right_arrow_input_event)
	speed_button.connect("input_event", self._on_speed_button_input_event)

# TODO: for the arrow keys make the input recognize when it is being held down not just when it is clicked
func _on_up_arrow_input_event(viewport: Node, event: InputEvent, shape_idx: int ) -> void:
	if event is InputEventMouseButton and event.pressed:
		print("Up arrow clicked")
		
func _on_down_arrow_input_event(viewport: Node, event: InputEvent, shape_idx: int ) -> void:
	if event is InputEventMouseButton and event.pressed:
		print("Down arrow clicked")

func _on_left_arrow_input_event(viewport: Node, event: InputEvent, shape_idx: int ) -> void:
	if event is InputEventMouseButton and event.pressed:
		print("Left arrow clicked")

func _on_right_arrow_input_event(viewport: Node, event: InputEvent, shape_idx: int ) -> void:
	if event is InputEventMouseButton and event.pressed:
		print("Right arrow clicked")

func _on_speed_button_input_event(viewport: Node, event: InputEvent, shape_idx: int ) -> void:
	if event is InputEventMouseButton and event.pressed:
		if fast_panning:
			fast_panning = false
			print("Panning speed set to slow")
		else:
			fast_panning = true
			print("Panning speed set to fast")
