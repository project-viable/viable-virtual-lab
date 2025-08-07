## Imbues a `SelectableCanvasGroup` with the power of being clicked.
class_name SelectableComponent
extends InteractableComponent


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


func is_hovered() -> bool: return interact_canvas_group.is_mouse_hovering()
func get_draw_order() -> int: return interact_canvas_group.draw_order_this_frame
func get_absolute_z_index() -> int: return Util.get_absolute_z_index(interact_canvas_group)

func get_interactions() -> Array[InteractInfo]:
	# TODO: Use a better system instead of only having the single left-click interaction with a
	# hard-coded name.
	return [InteractInfo.new(InteractInfo.Kind.PRIMARY, "Activate")]

func start_targeting(_k: InteractInfo.Kind) -> void:
	interact_canvas_group.is_outlined = true

func stop_targeting(_k: InteractInfo.Kind) -> void:
	interact_canvas_group.is_outlined = false

func start_interact(_k: InteractInfo.Kind) -> void:
	match press_mode:
		PressMode.HOLD:
			start_holding()
			started_holding.emit()
		PressMode.PRESS:
			press()
			pressed.emit()

func stop_interact(_k: InteractInfo.Kind) -> void:
	stopped_holding.emit()
	stop_holding()

## (virtual) called when the sprite group is clicked (only when `press_mode` is `HOLD`).
func start_holding() -> void: pass

## (virtual) called when the sprite group is let go of (only when `press_mode` is `HOLD`).
func stop_holding() -> void: pass

## (virtual) called when the sprite group is simply clicked (only when `press_mode` is `PRESS`).
func press() -> void: pass
