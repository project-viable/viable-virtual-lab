extends TextureRect

# Knob properties
var current_angle: float = 0.0
# Focus level (0 to 1)
var focus_level: float = 0.5
var snap_positions: int = 30
# Angle between each snap position (in degrees)
var snap_angle: float = 360.0 / snap_positions

signal focus_changed(level: float)

@onready var left_area: Area2D = $left_area
@onready var right_area: Area2D = $right_area

func _ready() -> void:
	left_area.input_pickable = true
	right_area.input_pickable = true

	left_area.connect("input_event", self._on_left_area_input_event)
	right_area.connect("input_event", self._on_right_area_input_event)
	# Set the pivot point to the center of the knob
	pivot_offset = size / 2

func _on_left_area_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	print("Input event detected on left area")
	if event is InputEventMouseButton and event.pressed:
		snap_left()
		print("left")

func _on_right_area_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	print("Input event detected on right area")
	if event is InputEventMouseButton and event.pressed:
		snap_right()
		print("right")

func snap_left() -> void:
	# Increment the angle to the next snap position
	current_angle += snap_angle

	# Wrap the angle to stay within 0° to 360°
	current_angle = wrapf(current_angle, 0.0, 360.0)

	# Update focus level (0 to 1)
	focus_level = current_angle / 360.0
	print("Focus Level: ", focus_level)  # Debugging

	# Update the knob's rotation
	rotation = current_angle
	
	# Emit signal or update shader
	#update_focus(focus_level)
	
func snap_right() -> void:
	# Increment the angle to the next snap position
	current_angle -= snap_angle

	# Wrap the angle to stay within 0° to 360°
	current_angle = wrapf(current_angle, 0.0, 360.0)

	# Update focus level (0 to 1)
	focus_level = current_angle / 360.0
	print("Focus Level: ", focus_level)  # Debugging

	# Update the knob's rotation
	rotation = current_angle
	
	# Emit signal or update shader
	#update_focus(focus_level)
