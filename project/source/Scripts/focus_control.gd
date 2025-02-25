extends Control

@onready var left_area: Control = $left_area
@onready var right_area: Control = $right_area
@onready var knob_sprite: Sprite2D = $focus_knob

var microscope_image: Sprite2D

# Knob properties
var current_angle: float = 0.0
# Focus level (0 to 1)
var focus_level: float = 0.5
var snap_positions: int = 30
# Angle between each snap position (in degrees)
var snap_angle: float = 360.0 / snap_positions

#signal focus_changed(level: float)



func _ready() -> void:
#
	left_area.mouse_filter = Control.MOUSE_FILTER_STOP
	right_area.mouse_filter = Control.MOUSE_FILTER_STOP
	
	left_area.gui_input.connect(_on_left_area_input)
	right_area.gui_input.connect(_on_right_area_input)
	
	var root: SceneTree = get_tree()
	var root_node: Window = root.root
	var current_scene: Node = root_node.get_child(root_node.get_child_count() - 1)
	
	
	microscope_image = find_child("microscope_iamge") as Sprite2D
	if not microscope_image:
		var parent: Node = get_parent()
		microscope_image = parent.get_node_or_null("microscope_image") as Sprite2D

func _on_left_area_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		snap_left()

func _on_right_area_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		snap_right()


func snap_left() -> void:
	# Increment the angle to the next snap position
	current_angle -= snap_angle

	# Wrap the angle to stay within 0° to 360°
	current_angle = wrapf(current_angle, 0.0, 360.0)

	# Update focus level (0 to 1)
	#TODO fix this
	focus_level -= current_angle / 360.0
	print("Focus Level: ", focus_level)  # Debugging

	# Update the knob's rotation
	knob_sprite.rotation_degrees = current_angle
	
	update_focus(focus_level)
	
func snap_right() -> void:
	# Increment the angle to the next snap position
	current_angle += snap_angle

	# Wrap the angle to stay within 0° to 360°
	current_angle = wrapf(current_angle, 0.0, 360.0)

	# Update focus level (0 to 1)
	#TODO fix this
	focus_level += current_angle / 360.0
	print("Focus Level: ", focus_level)  # Debugging

	# Update the knob's rotation
	knob_sprite.rotation_degrees = current_angle
	
	update_focus(focus_level)
	
func update_focus(level: float) -> void:
	if microscope_image.material:
		microscope_image.material.set("shader_parameter/blur_amount", level)
