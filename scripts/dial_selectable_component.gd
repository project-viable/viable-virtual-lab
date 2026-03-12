class_name DialSelectableComponent
extends SelectableComponent
## Allows a [SelectableCanvasGroup] to be rotated by clicking and dragging.


## Emitted when the dial is rotated by [param angle], in radians.
signal rotated(angle: float)


@export_custom(PROPERTY_HINT_NONE, "suffix:rad/px") var angle_per_mouse_distance: float = PI / 200
## If set to a value greater than zero, the dial will be divided into a set of equally distributed
## notches, and rotation will only rotate to these notches. Note: This doesn't work quite right at
## the moment.
@export var num_notches: int = 0


var _local_grab_pos := Vector2.ZERO
var _is_holding := false
var _mouse_motion := Vector2.ZERO


func _enter_tree() -> void:
	super()
	interact_info.description = "+ drag to rotate dial"
	Cursor.actual_mouse_moved_relative.connect(func(r: Vector2) -> void:
		_mouse_motion += r
	)

func _physics_process(_delta: float) -> void:
	var mouse_motion_this_tick := _mouse_motion
	_mouse_motion = Vector2.ZERO

	# Can't rotate if we were grabbed in the center.
	if not _is_holding or _local_grab_pos.is_zero_approx(): return

	var angle: float = -_local_grab_pos.orthogonal().normalized() \
			.dot(Util.direction_to_local(interact_canvas_group, mouse_motion_this_tick)) \
			* angle_per_mouse_distance
	var new_rotation: float = interact_canvas_group.rotation + angle

	if num_notches > 0:
		var notch_angle := TAU / num_notches
		var cur_notch := roundi(interact_canvas_group.rotation / notch_angle)
		var new_notch := roundi(new_rotation / notch_angle)
		new_rotation = new_notch * notch_angle
		angle = (new_notch - cur_notch) * notch_angle

	interact_canvas_group.rotation = new_rotation
	Cursor.virtual_mouse_position = interact_canvas_group.to_global(_local_grab_pos)
	rotated.emit(angle)

func _start_holding() -> void:
	_local_grab_pos = interact_canvas_group.to_local(Cursor.virtual_mouse_position)
	Cursor.automatically_move_with_mouse = false
	_is_holding = true

func _stop_holding() -> void:
	_is_holding = false
	Cursor.automatically_move_with_mouse = true
