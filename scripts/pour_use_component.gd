extends UseComponent
class_name PourUseComponent
## Makes it possible to pour using a [SpillComponent] into a [ContainerInteractableArea].
##
## The position of the [ContainerInteractableArea] is treated as a "good spot to pour into". This
## object will first be moved to a target position and then tilted about the cursor to a global
## angle of [member tilt_angle]. The target position is such that, when this object is tilted, the
## position of [member spill_component] will be equal to
## [code]a.global_position + pour_offset[/code], where [code]a[/code] is the target
## [ContainerInteractableArea].


signal started_pouring()
signal stopped_pouring()


## While pouring, this will be set to spill into the target container.
@export var spill_component: SpillComponent
## Body to tilt while pouring. If this is not set in the editor, then it will automatically be set
## to this component's parent node.
@export var body: LabBody
## Angle, in radians, that [member body] will be tilted to while pouring. By default, tilt to the
## left.
@export_custom(PROPERTY_HINT_NONE, "suffix:rad") var tilt_angle: float = -3 * PI / 4
## Average speed the object moves to get to the target position.
@export_custom(PROPERTY_HINT_NONE, "suffix:1/s") var move_speed: float = 100
## Average speed the object rotates to its target tilt.
@export_custom(PROPERTY_HINT_NONE, "suffix:rad/s") var tilt_speed: float = PI / 2
## Offset in global coordinates from the location of the target [ContainerInteractableArea] to the
## final destination of [member spill_component].
@export var pour_offset: Vector2 = Vector2(0, -10)
## The container will start being tilted when the container is within [member pour_range] units of
## the target position.
@export var pour_range: float = 20


var _move_duration := 1.0
var _tilt_duration := 1.0

# Start and target hand positions.
var _start_pos: Vector2 = Vector2.ZERO
var _target_pos: Vector2 = Vector2.ZERO
# These will be greater than zero if we're moving to the pour target.
var _move_duration_left: float = 0.0
var _tilt_duration_left: float = 0.0


func _enter_tree() -> void:
	if not body: body = get_parent() as LabBody

func _physics_process(delta: float) -> void:
	if not body or not spill_component: return

	var is_in_pour_range := body.get_global_hand_pos().distance_to(_target_pos) <= pour_range

	# Stop allowing further pouring if the container is taken outside of the pour range after being
	# moved into it.
	if spill_component.target_container and not is_in_pour_range and _move_duration_left <= 0:
		_leave_pour_mode()

	_move_duration_left = move_toward(_move_duration_left, 0.0, delta)

	if _move_duration_left > 0.0:
		var t: float = 1.0 - _move_duration_left / _move_duration
		# Move the body to get the hand in the right position.
		body.global_position = body.global_position - body.get_global_hand_pos() + lerp(_start_pos, _target_pos, ease(t, 0.2))

	# Only tilt when close enough.
	if is_in_pour_range:
		_tilt_duration_left = move_toward(_tilt_duration_left, 0.0, delta)
	if _tilt_duration_left > 0.0:
		var t: float = 1.0 - _tilt_duration_left / _tilt_duration
		body.set_global_rotation_about_cursor(lerp(0.0, tilt_angle, ease(t, 0.2)))

func get_interactions(area: InteractableArea) -> Array[InteractInfo]:
	var results: Array[InteractInfo] = []

	# If the user stops pouring but is still within range to pour, allow them to continue, even if
	# the object is not explicitly overlapping the target container.
	var can_continue_pouring: bool = spill_component.target_container \
			and body and body.get_global_hand_pos().distance_to(_target_pos) <= pour_range

	if area is ContainerInteractableArea \
			and area.is_in_group(&"container:pour") \
			and area.container_component and spill_component \
			or can_continue_pouring:
		results.push_back(InteractInfo.new(InteractInfo.Kind.SECONDARY, "(hold) Pour"))

	if results and not Game.main.get_camera_focus_owner():
		results.push_back(InteractInfo.new(InteractInfo.Kind.INSPECT, "Zoom in to pour"))

	return results

func start_use(area: InteractableArea, kind: InteractInfo.Kind) -> void:
	match kind:
		InteractInfo.Kind.SECONDARY:
			if body:
				body.disable_drop = true
				body.disable_rotate_upright = true
				body.disable_follow_cursor = true

				_start_pos = body.get_global_hand_pos()

			# We only need to recompute this stuff if we're targeting a new object.
			if body and spill_component and area:
				spill_component.target_container = area.container_component

				# TODO: We're assuming with this calculation that `spill_component`'s position is
				# relative to `body`, which is not necessarily correct if it's not a direct child of
				# `body`.
				var hand_pos := body.get_local_hand_pos()
				_target_pos = area.global_position + pour_offset \
						+ (hand_pos - spill_component.position).rotated(tilt_angle)

			_move_duration = _start_pos.distance_to(_target_pos) / move_speed
			_tilt_duration = abs(tilt_angle) / tilt_speed

			_move_duration_left = _move_duration
			_tilt_duration_left = _tilt_duration

			started_pouring.emit()

		#InteractInfo.Kind.INSPECT:
		#	var parent_body := get_parent() as CollisionObject2D
		#	var area_parent_body := area.get_parent() as CollisionObject2D
		#	if not parent_body or not area_parent_body: return
		#	Game.main.focus_camera_on_rect(Util.get_global_bounding_box(parent_body).merge(Util.get_global_bounding_box(area_parent_body)))
		#	Game.main.set_camera_focus_owner(self)

func stop_use(_area: InteractableArea, kind: InteractInfo.Kind) -> void:
	match kind:
		InteractInfo.Kind.SECONDARY:
			body.disable_drop = false
			body.disable_rotate_upright = false
			body.disable_follow_cursor = false
			_move_duration_left = 0.0
			_tilt_duration_left = 0.0
			stopped_pouring.emit()

func _leave_pour_mode() -> void:
	spill_component.target_container = null
	if body:
		body.disable_drop = false
		body.disable_rotate_upright = false
		body.disable_follow_cursor = false
