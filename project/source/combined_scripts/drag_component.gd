## Allows a `RigidBody2D` to be dragged and dropped with the mouse.
class_name DragComponent
extends SelectableComponent


## The body to be dragged.
@export var body: LabBody

var _offset: Vector2 = Vector2.ZERO
var _velocity: Vector2 = Vector2.ZERO

# The body's interaction area for toggling area monitoring
var interaction_area: InteractionArea

func _ready() -> void:
	super()
	press_mode = PressMode.PRESS
	interaction_area = get_parent().find_children("", "InteractionArea", false).front()

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
	body.start_dragging()
	Interaction.active_drag_component = self
	interaction_area.set_deferred(&"monitoring", false) # A body that is dragged should not be able to detect anything

	# We can't just use `move_to_front` because it doesn't properly reorder the `_draw` calls,
	# whose specific order is required to determine which one is in front.
	var body_parent := body.get_parent()
	if body_parent:
		body_parent.call_deferred(&"remove_child", body)
		body_parent.call_deferred(&"add_child", body)

	_offset = body.get_local_mouse_position()

func _unhandled_input(e: InputEvent) -> void:
	# Since the `SelectableComponent` is no longer considered hovered while this is being dragged,
	# `press` will not activate when the button is pressed. So it needs to be handled here
	# instead.
	if e.is_action_pressed(&"DragLabObject") and is_active():
		body.stop_dragging()
		Interaction.active_drag_component = null
		Interaction.clear_interaction_stack()
		interaction_area.set_deferred(&"monitoring", true) # Re-enable detection when the body is not being dragged

		# Fling the body after dragging depending on how it was moving when being dragged.
		var global_offset := body.to_global(_offset) - body.global_position
		body.call_deferred(&"apply_impulse", _velocity / 10.0, global_offset)

	# If this is called first, then the this will be grabbed and immediately released.
	super(e)



func is_active() -> bool: return Interaction.active_drag_component == self
