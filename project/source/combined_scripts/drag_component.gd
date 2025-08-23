## Allows a `RigidBody2D` to be dragged and dropped with the mouse.
class_name DragComponent
extends SelectableComponent


## The body to be dragged.
@export var body: LabBody

static var _pick_up_interaction := InteractInfo.new(InteractInfo.Kind.PRIMARY, "Pick up")
static var _put_down_interaction := InteractInfo.new(InteractInfo.Kind.PRIMARY, "Put down")


func _ready() -> void: press_mode = PressMode.PRESS

func press() -> void:
	if is_active(): stop_dragging()
	else: start_dragging()

func get_interactions() -> Array[InteractInfo]:
	if is_active(): return [_put_down_interaction]
	else: return [_pick_up_interaction]

func start_targeting(_k: InteractInfo.Kind) -> void:
	if not is_active(): interact_canvas_group.is_outlined = true

func start_dragging() -> void:
	Interaction.active_drag_component = self
	interact_canvas_group.is_outlined = false
	body.start_dragging()

## Can be safely called from elsewhere. Also cancels any interaction that was pressed down.
func stop_dragging() -> void:
	Interaction.active_drag_component = null
	body.stop_dragging()

func is_active() -> bool: return Interaction.active_drag_component == self
