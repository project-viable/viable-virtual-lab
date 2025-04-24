class_name FocusControl
extends Control

@onready var left_area: Control = $left_area
@onready var right_area: Control = $right_area
@onready var knob_sprite: Sprite2D = $focus_knob

# Knob properties
var current_angle: float = 0.0
# Focus level (0 to 1)
var focus_level: float = 0.0
var snap_positions: int = 10
# Angle between each snap position (in degrees)
var snap_angle: float = 360.0 / snap_positions

var FOCUS_CHANGE: float = 0.05 

signal focus_changed(level: float)

func _ready() -> void:
	left_area.mouse_filter = Control.MOUSE_FILTER_STOP
	right_area.mouse_filter = Control.MOUSE_FILTER_STOP
	
	left_area.gui_input.connect(_on_left_area_input)
	right_area.gui_input.connect(_on_right_area_input)

	# Initing to random blur level
	focus_level = randf_range(0.75, 1)
	focus_changed.emit(focus_level)

func _on_left_area_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		snap_left()

func _on_right_area_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		snap_right()


func snap_left() -> void:
	LabLog.log("Focused down", false, false)
	# Increment the angle to the next snap position
	current_angle -= snap_angle

	# Wrap the angle to stay within 0° to 360°
	current_angle = wrapf(current_angle, 0.0, 360.0)
	
	# Update the knob's rotation
	knob_sprite.rotation_degrees = current_angle

	# Update focus level (0 to 1)
	focus_level = max(0, focus_level - FOCUS_CHANGE)

	focus_changed.emit(focus_level)
	
func snap_right() -> void:
	LabLog.log("Focused up", false, false)
	# Increment the angle to the next snap position
	current_angle += snap_angle

	# Wrap the angle to stay within 0° to 360°
	current_angle = wrapf(current_angle, 0.0, 360.0)
	
	# Update the knob's rotation
	knob_sprite.rotation_degrees = current_angle

	# Update focus level (0 to 1)
	focus_level = min(1, focus_level + FOCUS_CHANGE)
	
	focus_changed.emit(focus_level)
