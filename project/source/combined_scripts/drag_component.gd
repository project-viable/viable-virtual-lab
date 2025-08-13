## Allows a `RigidBody2D` to be dragged and dropped with the mouse.
class_name DragComponent
extends SelectableComponent


## The body to be dragged.
@export var body: LabBody


var _offset: Vector2 = Vector2.ZERO
var _velocity: Vector2 = Vector2.ZERO


static var _pick_up_interaction := InteractInfo.new(InteractInfo.Kind.PRIMARY, "Pick up")
static var _put_down_interaction := InteractInfo.new(InteractInfo.Kind.PRIMARY, "Put down")


func _ready() -> void:
	press_mode = PressMode.PRESS

func _physics_process(delta: float) -> void:
	if is_active():
		if abs(body.global_rotation) > 0.001:
			var is_rotating_clockwise := body.global_rotation < 0
			body.global_rotation -= body.global_rotation * delta * 50

			if is_rotating_clockwise: body.global_rotation = min(0.0, body.global_rotation)
			else: body.global_rotation = max(0.0, body.global_rotation)

		var dest_pos := body.to_global(body.get_local_mouse_position() - _offset)
		_velocity = (dest_pos - body.global_position) / delta
		body.global_position = dest_pos

func press() -> void:
	if is_active(): stop_dragging()
	else: start_dragging()

func get_interactions() -> Array[InteractInfo]:
	if is_active(): return [_put_down_interaction]
	else: return [_pick_up_interaction]

func start_targeting(_k: InteractInfo.Kind) -> void:
	if not is_active(): interact_canvas_group.is_outlined = true

func start_dragging() -> void:
	body.start_dragging()
	Interaction.active_drag_component = self
	interact_canvas_group.is_outlined = false

	# We can't just use `move_to_front` because it doesn't properly reorder the `_draw` calls,
	# whose specific order is required to determine which one is in front.
	var body_parent := body.get_parent()
	if body_parent:
		body_parent.call_deferred(&"remove_child", body)
		body_parent.call_deferred(&"add_child", body)

	_offset = body.get_local_mouse_position()

## Can be safely called from elsewhere. Also cancels any interaction that was pressed down.
func stop_dragging() -> void:
	body.stop_dragging()
	Interaction.active_drag_component = null
	Interaction.clear_interaction_stack()
	body.set_deferred(&"linear_velocity", _velocity / 5.0)

func is_active() -> bool: return Interaction.active_drag_component == self
