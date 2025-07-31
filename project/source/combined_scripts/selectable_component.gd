## Imbues a `SelectableCanvasGroup` with the power of being clicked.
class_name SelectableComponent
extends Node2D


enum PressMode
{
	HOLD, ## This should be used for any "clicking and dragging" behavior. On mouse down, `is_held()` will be true until the mouse is released.
	PRESS, ## Activate immediately upon mouse down. `is_held()` is never true. This should be used for buttons that you click once.
}


signal pressed()
signal started_holding()
signal stopped_holding()


## This will be outlined when it's hovered, and clicking will cause it to be held.
@export var interact_canvas_group: SelectableCanvasGroup

## Determines how clicking interacts with this component.
@export var press_mode: PressMode = PressMode.HOLD


func _ready() -> void:
	add_to_group(&"selectable_component")

func _process(_delta: float) -> void:
	interact_canvas_group.is_outlined = _is_hovering() and not is_held() \
			and not Input.is_action_pressed(&"DragLabObject")

# `start_targeting`, `stop_targeting`, `start_interact`, and `stop_interact` are all automatically
# called in `Interaction` (the singleton).
func start_targeting() -> void: pass
func stop_targeting() -> void: pass

func start_interact() -> void:
	match press_mode:
		PressMode.HOLD:
			Interaction.held_selectable_component = self
			start_holding()
			started_holding.emit()
			GameState.is_dragging = true
		PressMode.PRESS:
			press()
			pressed.emit()

func stop_interact() -> void:
	stopped_holding.emit()
	stop_holding()
	Interaction.held_selectable_component = null
	GameState.is_dragging = false

## (virtual) called when the sprite group is clicked (only when `press_mode` is `HOLD`).
func start_holding() -> void: pass

## (virtual) called when the sprite group is let go of (only when `press_mode` is `HOLD`).
func stop_holding() -> void: pass

## (virtual) called when the sprite group is simply clicked (only when `press_mode` is `PRESS`).
func press() -> void: pass

func is_held() -> bool: return Interaction.held_selectable_component == self

func _is_hovering() -> bool: return Interaction.hovered_selectable_component == self
