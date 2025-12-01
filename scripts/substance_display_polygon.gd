## Displays the contents of a `ContainerComponent` inside of this polygon such that its apparent
## depth matches the expected depth based on the volume of substances and the polygon.
class_name SubstanceDisplayPolygon
extends Polygon2D


# Percentage of angular velocity removed per second.
const SLOSH_MIN_ANGULAR_DAMP: float = 10
const SLOSH_MAX_ANGULAR_DAMP: float = 60

const SLOSH_PENDULUM_LENGTH: float = 0.02
const SLOSH_PENDULUM_MASS: float = 1
const SLOSH_PENDULUM_MOMENT_OF_INERTIA = SLOSH_PENDULUM_MASS * pow(SLOSH_PENDULUM_LENGTH, 2)


@export var source: ContainerComponent


# We model the sloshing of the fluid as a pendulum deciding the fluid's down direction.
var _global_gravity: Vector2
@warning_ignore("confusable_identifier")
var _slosh_target_θ: float
@warning_ignore("confusable_identifier")
var _slosh_θ: float
# Angular velocity.
@warning_ignore("confusable_identifier")
var _slosh_ω: float = 0

var _fill_area_cache := PolygonFillAreaCache.new()
# Transforms a local point into a space where [member _last_cached_down_dir] points in the negative
# y direction.
var _local_to_fill := Transform2D()
var _last_cached_down_dir: Vector2
@onready var _container_vertices: PackedVector2Array = polygon
@onready var _container_tris: PackedInt32Array = Geometry2D.triangulate_polygon(_container_vertices)


static var _shader: Shader = preload("res://shaders/substance_polygon.gdshader")


func _enter_tree() -> void:
	_global_gravity = ProjectSettings.get_setting("physics/2d/default_gravity_vector")
	_global_gravity *= ProjectSettings.get_setting("physics/2d/default_gravity")
	_slosh_target_θ = Util.direction_to_local(self, _global_gravity).angle()
	_slosh_θ = _slosh_target_θ
	_last_cached_down_dir = Vector2.from_angle(_slosh_θ)

	material = ShaderMaterial.new()
	material.shader = _shader
	set_notify_transform(true)

func _ready() -> void:
	_set_down_dir(_last_cached_down_dir)

func _physics_process(delta: float) -> void:
	var viscosity := 0.0
	for s in source.substances:
		viscosity += s.get_viscosity() * s.get_volume()
	viscosity /= source.get_total_volume()
	# If we just use viscosity linearly, then mid-level viscosities are barely different from low
	# ones.
	var angular_damp_t: float = ease(viscosity, 0.4)
	var angular_damp: float = lerp(SLOSH_MIN_ANGULAR_DAMP, SLOSH_MAX_ANGULAR_DAMP, angular_damp_t)

	_slosh_target_θ = Util.direction_to_local(self, _global_gravity).angle()
	var g := Util.direction_to_local(self, _global_gravity).length() / 1000
	var θ := angle_difference(_slosh_target_θ, _slosh_θ)
	var τ := -g * SLOSH_PENDULUM_MASS * SLOSH_PENDULUM_LENGTH * sin(θ)
	_slosh_ω += τ / SLOSH_PENDULUM_MOMENT_OF_INERTIA * delta
	@warning_ignore("confusable_identifier")
	var prev_slosh_ω := _slosh_ω
	_slosh_ω -= _slosh_ω * angular_damp * delta
	# Damping should not be able to cause the sloshing to move in the other direction.
	if sign(_slosh_ω) != sign(prev_slosh_ω): _slosh_ω = 0
	_slosh_θ += _slosh_ω * delta

func _process(_delta: float) -> void:
	if not source: return

	_set_down_dir_if_changed(Vector2.from_angle(_slosh_θ))

	var total_container_volume: float = source.container_volume
	var total_area := _fill_area_cache.get_total_area()

	var depths: Array[float] = []
	depths.assign(source.substances.map(func(s: Substance) -> float: return s.get_volume()))

	var colors: Array[Color] = []
	colors.assign(source.substances.map(func(s: Substance) -> Color: return s.get_color()))

	var cur_volume := 0.0
	for i in range(0, len(depths)):
		cur_volume += depths[i]
		# The depths have their y coordinates inverted, so uninvert them.
		depths[i] = -_fill_area_cache.get_y_value_from_area(cur_volume * total_area / total_container_volume)

	material.set("shader_parameter/depth_offsets", depths)
	material.set("shader_parameter/substance_colors", colors)
	material.set("shader_parameter/substance_count", len(depths))
	material.set("shader_parameter/down_direction", _last_cached_down_dir)

## Get the substance displayed at the point [param pos], given in local coordinates. If no
## substance is shown, return [code]null[/code]. This returns a reference rather than a copy, so
## modifying the substance will directly modify the container. This function does [i]not[/i] check
## whether [param pos] is actually inside the polygon, since that can make it a bit finicky to try
## to get substances near the edge of the polygon, like when the tip of the pipette is near the
## bottom of the container. That kind of thing should be handled using collisions, instead.
func get_substance_at(pos: Vector2) -> Substance:
	var cur_volume: float = 0
	var volume := _fill_area_cache.get_area_at_y_value((_local_to_fill * pos).y) \
			* source.container_volume \
			/ _fill_area_cache.get_total_area()

	for s in source.substances:
		cur_volume += s.get_volume()
		if cur_volume >= volume: return s
	
	return null

## Convenience function. Same as [method get_substance_at], but takes a position in global
## coordinates.
func get_substance_at_global(pos: Vector2) -> Substance:
	return get_substance_at(to_local(pos))

## Get the down direction of the top of the fluid, in local coordinates. This will often not
## correspond with the global down direction if the fluid is sloshing.
func get_down_dir() -> Vector2:
	return Vector2.ZERO

func _set_down_dir_if_changed(down: Vector2) -> void:
	if not down.is_equal_approx(_last_cached_down_dir):
		_set_down_dir(down)

func _set_down_dir(down: Vector2) -> void:
	_last_cached_down_dir = down
	# We rotate it to point the down direction upwards, because it fills from -y to +y.
	_local_to_fill = Transform2D().rotated(down.angle_to(Vector2.UP))
	_fill_area_cache.set_from_triangulated_polygon(_container_vertices, _container_tris, _local_to_fill)
