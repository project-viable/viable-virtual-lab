extends UseComponent


@export var container: ContainerComponent
## The node that will be rotated while swirling.
@export var node_to_rotate: Node2D
## Angle the container is held at relative to straight down, in radians.
@export var hold_angle: float = PI / 16
## Speed of swirling, in radians per second.
@export var swirl_speed: float = 7 * PI
## Radius of the hand's movement circle when rotating.
@export var swirl_circle_radius: float = 10
## Offset of the point where the container is held while swirled (center of rotation).
@export var rotation_center_offset: Vector2 = Vector2.ZERO


var _is_swirling := false
var _swirl_time := 0.0
var _orig_transform: Transform2D


func _process(delta: float) -> void:
	if _is_swirling:
		_swirl_time += delta
		var angle: float = sin(swirl_speed * _swirl_time) * tan(hold_angle)
		var trans := Vector2(-sin(swirl_speed * _swirl_time) * swirl_circle_radius, 0)
		node_to_rotate.transform = _orig_transform.translated(-rotation_center_offset).rotated(angle).translated(rotation_center_offset + trans)

func get_interactions(_area: InteractableArea) -> Array[InteractInfo]:
	return [InteractInfo.new(InteractInfo.Kind.TERTIARY, "(hold) Swirl")]

func start_use(_area: InteractableArea, _kind: InteractInfo.Kind) -> void:
	_is_swirling = true
	_swirl_time = 0
	_orig_transform = node_to_rotate.transform

	# TODO: Don't hard-code this for just TAE.
	for s in container.substances:
		if s is TAEBufferSubstance:
			s.is_mixing = true

func stop_use(_area: InteractableArea, _kind: InteractInfo.Kind) -> void:
	_is_swirling = false
	node_to_rotate.transform = _orig_transform

	# TODO: Don't hard-code this for just TAE.
	for s in container.substances:
		if s is TAEBufferSubstance:
			s.is_mixing = false
