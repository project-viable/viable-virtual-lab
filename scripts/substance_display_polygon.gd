## Displays the contents of a `ContainerComponent` inside of this polygon such that its apparent
## depth matches the expected depth based on the volume of substances and the polygon.
class_name SubstanceDisplayPolygon
extends Polygon2D

@export var source: ContainerComponent


var _fill_area_cache := PolygonFillAreaCache.new()
# Transforms a local point into a space where [member _last_cached_down_dir] points in the negative
# y direction.
var _local_to_fill := Transform2D()
@onready var _container_vertices: PackedVector2Array = polygon
@onready var _container_tris: PackedInt32Array = Geometry2D.triangulate_polygon(_container_vertices)
@onready var _last_cached_down_dir: Vector2 = Util.direction_to_local(self, Vector2.DOWN)


static var _shader: Shader = preload("res://shaders/substance_polygon.gdshader")


func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSFORM_CHANGED:
		var down_dir := Util.direction_to_local(self, Vector2.DOWN)
		if not down_dir.is_equal_approx(_last_cached_down_dir):
			_set_down_dir(down_dir)

func _enter_tree() -> void:
	material = ShaderMaterial.new()
	material.shader = _shader
	set_notify_transform(true)

func _ready() -> void:
	_set_down_dir(_last_cached_down_dir)

func _process(_delta: float) -> void:
	if not source: return

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

func _set_down_dir(down: Vector2) -> void:
	_last_cached_down_dir = down
	# We rotate it to point the down direction upwards, because it fills from -y to +y.
	_local_to_fill = Transform2D().rotated(down.angle_to(Vector2.UP))
	_fill_area_cache.set_from_triangulated_polygon(_container_vertices, _container_tris, _local_to_fill)
