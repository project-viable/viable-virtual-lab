extends UseComponent


@export var container: ContainerComponent
## The node that will be rotated while swirling.
@export var node_to_rotate: Node2D
## If not set, this will automatically be set to this node's parent.
@export var body: LabBody
## Angle the container is held at relative to straight down, in radians.
@export_custom(PROPERTY_HINT_NONE, "suffix:rad") var hold_angle: float = PI / 16
## Speed of swirling, in radians per second.
@export_custom(PROPERTY_HINT_NONE, "suffix:rad/s") var swirl_speed: float = 7 * PI
## Radius of the hand's movement circle when rotating.
@export var swirl_circle_radius: float = 10
## Offset of the point where the container is held while swirled (center of rotation).
@export var rotation_center_offset: Vector2 = Vector2.ZERO

## If set, then this region will be zoomed in on when the user starts swirling.
@export var region_provider: RegionProvider


var _is_swirling := false
var _swirl_time := 0.0
var _orig_transform: Transform2D


func _ready() -> void:
	Game.main.camera_focus_owner_changed.connect(_on_main_camera_focus_owner_changed)
	if not body: body = get_parent() as LabBody

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
	container.send_event(MixSubstanceEvent.new(true))
	body.disable_follow_cursor = true
	body.disable_drop = true
	if region_provider:
		Game.main.focus_camera_on_rect(region_provider.get_region())
		Game.main.set_camera_focus_owner(self)

func stop_use(_area: InteractableArea, _kind: InteractInfo.Kind) -> void:
	_stop_swirling()

func _on_main_camera_focus_owner_changed(focus_owner: Node) -> void:
	if focus_owner != self and _is_swirling:
		_stop_swirling()

func _stop_swirling() -> void:
	_is_swirling = false
	node_to_rotate.transform = _orig_transform
	container.send_event(MixSubstanceEvent.new(false))
	body.disable_follow_cursor = false
	body.disable_drop = false
	if Game.main.get_camera_focus_owner() == self:
		Game.main.return_to_current_workspace()
