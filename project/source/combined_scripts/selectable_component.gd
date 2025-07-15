## Imbues a `SelectableCanvasGroup` with the power of being clicked.
class_name SelectableComponent
extends Node2D


signal started_holding()
signal stopped_holding()


## This will be outlined when it's hovered, and clicking will cause it to be held.
@export var interact_canvas_group: SelectableCanvasGroup


## True when the mouse was clicked on the canvas group and is still being held down. By default,
## nothing in particular happens while a selectable component is held; this should be either done
## in the parent by connecting to the signals, or by making a class derived from this (for an
## example, see `DragComponent`).
var is_held: bool = false


func _ready() -> void:
	add_to_group(&"selectable_component")

func _process(_delta: float) -> void:
	interact_canvas_group.is_outlined = _is_hovering() and not is_held

func _unhandled_input(e: InputEvent) -> void:
	if e.is_action_pressed(&"DragLabObject") and _is_hovering():
		is_held = true
		start_holding()
		started_holding.emit()
		GameState.is_dragging = true
	elif e.is_action_released(&"DragLabObject") and is_held:
		stopped_holding.emit()
		stop_holding()
		is_held = false
		GameState.is_dragging = false

## (virtual) called when the sprite group is clicked.
func start_holding() -> void: pass

## (virtual) called when the sprite group is let go of.
func stop_holding() -> void: pass

func _is_hovering() -> bool: return Selectables.hovered_component == self
