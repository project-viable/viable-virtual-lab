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


enum PourState
{
	NONE,
	MOVING_TO_ZONE,
	IN_ZONE,
	POURING,
}


## When zooming in, a little extra space is given around the pour range zone to allow the container
## to be removed from that zone.
const POUR_RANGE_ZOOM_MARGIN := 5.0


## While pouring, this will be set to spill into the target container.
@export var spill_component: SpillComponent
## Body to tilt while pouring. If this is not set in the editor, then it will automatically be set
## to this component's parent node.
@export var body: LabBody
## Angle, in radians, that [member body] will be tilted to while pouring. By default, tilt to the
## left.
@export_custom(PROPERTY_HINT_NONE, "suffix:rad") var tilt_angle: float = -3 * PI / 4
## Angle that [member body] will be tilted to while in pour mode but not pouring. This can be used
## to prevent the body from tilting back and forth a massive amount while doing small adjustments.
@export_custom(PROPERTY_HINT_NONE, "suffix:rad") var standby_tilt_angle: float = -PI / 2
## Average speed the object moves to get to the target position.
@export_custom(PROPERTY_HINT_NONE, "suffix:1/s") var move_speed: float = 100
## Average speed the object rotates to its target tilt.
@export_custom(PROPERTY_HINT_NONE, "suffix:rad/s") var tilt_speed: float = PI / 2
## Average speed the object rotates when it's being tilted back up after stopping pouring.
@export_custom(PROPERTY_HINT_NONE, "suffix:rad/s") var untilt_speed: float = 2 * PI / 2
## Offset in global coordinates from the location of the target [ContainerInteractableArea] to the
## final destination of [member spill_component].
@export var pour_offset: Vector2 = Vector2(0, -10)
## The container will start being tilted when the container is within [member pour_range] units of
## the target position.
@export var pour_range: float = 20


var _pour_state := PourState.NONE

var _move_duration := 1.0
# Start and target hand positions.
var _start_pos: Vector2 = Vector2.ZERO
var _target_pos: Vector2 = Vector2.ZERO
# These will be greater than zero if we're moving to the pour target.
var _move_duration_left: float = 0.0
var _target_container: ContainerComponent = null
# Used to zoom in.
var _target_body: CollisionObject2D = null


func _enter_tree() -> void:
	if not body: body = get_parent() as LabBody

func _ready() -> void:
	Game.main.camera_focus_owner_changed.connect(_on_main_camera_focus_owner_changed)

func _physics_process(delta: float) -> void:
	if not body or not spill_component or _pour_state == PourState.NONE:
		return

	var is_in_pour_range := body.get_global_hand_pos().distance_to(_target_pos) <= pour_range

	# Handle the user dragging the container outside of the pour zone.
	if _pour_state == PourState.IN_ZONE and not is_in_pour_range:
		_leave_pour_mode()
		return

	if is_in_pour_range and _pour_state == PourState.MOVING_TO_ZONE:
		_pour_state = PourState.POURING
		spill_component.target_container = _target_container
		body.disable_follow_cursor = true
		started_pouring.emit()

	_move_duration_left = move_toward(_move_duration_left, 0.0, delta)

	if _move_duration_left > 0.0:
		var t: float = 1.0 - _move_duration_left / _move_duration
		# Move the body to get the hand in the right position.
		body.global_position = body.global_position - body.get_global_hand_pos() + lerp(_start_pos, _target_pos, ease(t, 0.2))

	# Tilt forward if in the pouring state or tilt back if we're just in the zone, not pouring.
	var target_angle: float = tilt_angle if _pour_state == PourState.POURING else standby_tilt_angle
	var speed: float = tilt_speed if _pour_state == PourState.POURING else untilt_speed
	body.set_global_rotation_about_cursor(move_toward(body.global_rotation, target_angle, speed * delta))

func get_interactions(area: InteractableArea) -> Array[InteractInfo]:
	var results: Array[InteractInfo] = []

	if area is ContainerInteractableArea \
			and area.is_in_group(&"container:pour") \
			and area.container_component and spill_component \
			or _pour_state == PourState.IN_ZONE:
		results.push_back(InteractInfo.new(InteractInfo.Kind.SECONDARY, "(hold) Pour"))

	return results

func start_use(area: InteractableArea, _kind: InteractInfo.Kind) -> void:
	if _pour_state == PourState.IN_ZONE:
		_pour_state = PourState.POURING
		spill_component.target_container = _target_container
		body.disable_follow_cursor = true
		started_pouring.emit()
	elif _pour_state == PourState.NONE:
		_pour_state = PourState.MOVING_TO_ZONE

		if body:
			body.disable_drop = true
			body.disable_rotate_upright = true
			body.disable_follow_cursor = true

		# We only need to recompute this stuff if we're targeting a new object.
		if body and spill_component and area:
			_target_container = area.container_component
			_target_body = area.get_parent() as CollisionObject2D

			_start_pos = body.get_global_hand_pos()

			# TODO: We're assuming with this calculation that `spill_component`'s position is
			# relative to `body`, which is not necessarily correct if it's not a direct child
			# of `body`.
			var hand_pos := body.get_local_hand_pos()
			_target_pos = area.global_position + pour_offset \
					+ (hand_pos - spill_component.position).rotated(tilt_angle)

		_move_duration = _start_pos.distance_to(_target_pos) / move_speed
		_move_duration_left = _move_duration

		_zoom_in()

func stop_use(_area: InteractableArea, _kind: InteractInfo.Kind) -> void:
	if _pour_state == PourState.POURING:
		_pour_state = PourState.IN_ZONE
		body.disable_follow_cursor = false
		spill_component.target_container = null
		stopped_pouring.emit()
	elif _pour_state == PourState.MOVING_TO_ZONE:
		_leave_pour_mode()

# Stop doing any of the pour stuff we were doing, returning to neutral.
func _leave_pour_mode() -> void:
	_target_container = null
	spill_component.target_container = null
	_pour_state = PourState.NONE
	if body:
		body.disable_drop = false
		body.disable_rotate_upright = false
		body.disable_follow_cursor = false
	Game.main.return_to_current_workspace()

func _zoom_in() -> void:
	if not _target_body: return
	var hand_rect := Util.make_centered_rect(_target_pos, Vector2.ONE * (pour_range * 2 + POUR_RANGE_ZOOM_MARGIN * 2))

	var region := Util.get_global_bounding_box(_target_body).merge(hand_rect)

	# Zoom very quickly to avoid too much time not seeing what's going on.
	Game.main.focus_camera_on_rect(region, 0.5)
	Game.main.set_camera_focus_owner(self)

func _on_main_camera_focus_owner_changed(focus_owner: Node) -> void:
	if _pour_state != PourState.NONE and focus_owner != self:
		_leave_pour_mode()
