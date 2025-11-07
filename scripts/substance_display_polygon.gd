## Displays the contents of a `ContainerComponent` inside of this polygon such that its apparent
## depth matches the expected depth based on the volume of substances and the polygon.
class_name SubstanceDisplayPolygon
extends Polygon2D

class QuadraticEquation extends Resource:
	# Coefficients.
	@export var a: float
	@export var b: float
	@export var c: float

	func _init(p_a: float = 0, p_b: float = 0, p_c: float = 0) -> void:
		a = p_a
		b = p_b
		c = p_c

	# Find a solution `x` for the equation `ax^2 + bx + c = k` such that `x` is
	# in the inclusive interval `[low, high]`. Returns NaN if no solution in that
	# interval is found or if all solutions are complex.
	func solve_in_range(k: float, low: float, high: float) -> float:
		# If `a` is zero, we need to solve it as a linear equation instead.
		if abs(a) < 0.001:
			if abs(b) < 0.001: return NAN
			return (k - c) / b
		var rad: float = b * b - 4 * a * (c - k)
		if rad < 0: return NAN

		var l := -b / (2 * a)
		var r := sqrt(rad) / (2 * a)

		var low_solution := l - r
		var high_solution := l + r

		if low <= low_solution and low_solution <= high: return low_solution
		if low <= high_solution and high_solution <= high: return high_solution
		return NAN

	func apply(x: float) -> float:
		return a * x * x + b * x + c

class AreaInterval:
	var low_area: float = 0
	var high_area: float = 0

	var low_depth: float = 0
	var high_depth: float = 0

	# Equation for total area that would be taken by fluid up the given depth.
	var area_equation: QuadraticEquation = QuadraticEquation.new()

	func _init(p_low_area: float, p_high_area: float, p_low_depth: float, p_high_depth: float,
		p_area_equation: QuadraticEquation) -> void:
		low_area = p_low_area
		high_area = p_high_area
		low_depth = p_low_depth
		high_depth = p_high_depth
		area_equation = p_area_equation


@export var source: ContainerComponent


## Global y coordinate of the top of the fluid.
var global_fluid_top_y_coord: float = 0

@onready var _container_vertices: PackedVector2Array = polygon
@onready var _container_tris: PackedInt32Array = Geometry2D.triangulate_polygon(_container_vertices)
@onready var _last_cached_rotation: float = global_rotation
var _area_intervals: Array[AreaInterval] = []


static var _shader: Shader = preload("res://shaders/substance_polygon.gdshader")


func _ready() -> void:
	material = ShaderMaterial.new()
	material.shader = _shader
	_update_area_intervals()
	pass

func _process(_delta: float) -> void:
	if not source: return

	if abs(global_rotation - _last_cached_rotation) > 0.001:
		_last_cached_rotation = global_rotation
		_update_area_intervals()

	var total_container_volume: float = source.container_volume
	var total_area: float = _area_intervals.back().high_area if _area_intervals else 0.0

	var depths: Array[float] = []
	depths.assign(source.substances.map(func(s: Substance) -> float: return s.get_volume()))

	var colors: Array[Color] = []
	colors.assign(source.substances.map(func(s: Substance) -> Color: return s.get_color()))

	var cur_volume := 0.0
	for i in range(0, len(depths)):
		cur_volume += depths[i]
		depths[i] = cur_volume
		depths[i] = global_position.y - _get_depth_for_area(cur_volume * total_area / total_container_volume)

	var zero_depth: float = global_position.y - _get_depth_for_area(0.0)
	global_fluid_top_y_coord = depths.back() if depths else zero_depth

	material.set("shader_parameter/depth_offsets", depths)
	material.set("shader_parameter/substance_colors", colors)
	material.set("shader_parameter/substance_count", len(depths))


func _update_area_intervals() -> void:
	# Two points are considered "the same" if they are within this distance
	# from each other. Since we're working on pixel scales, a hundredth of a
	# pixel is well within acceptable bounds.
	const tolerance := 0.01

	# Any triangle with at least one side parallel to the "ground" can have a
	# quadratic equation `f` defined over the interval `[s, e]` where `s` is
	# the lowest y coordinate of the triangle and `e` is the highest, such that
	# if `y` is the y coordinate of the top of the liquid sitting in the
	# container, `f(y)` will be the total area of that liquid. Since the sum of
	# two quadratic equations is also a quadratic equation, we can partition
	# the y coordinates into intervals where some set of triangle area
	# equations is completely defined.
	#
	# Because the triangles need to have at least one side parallel to the
	# ground, we start by "splitting" each triangle into two along a line
	# passing through the middlemost (height-wise) vertex.
	#
	# `cut_tris` consists of arrays in the form `[y_start, y_end, equation]`,
	# where `y_start` is the lowest y position of the cut triangle, and `y_end`
	# is the highest. `equation` is the quadratic equation, defined in that
	# interval, that will give the area from filling that one triangle to that
	# depth.
	var cut_tris: Array[Array] = []

	@warning_ignore("integer_division")
	for i in range(0, len(_container_tris) / 3):
		var vertices: Array[Vector2] = [
			_container_vertices[_container_tris[i * 3]],
			_container_vertices[_container_tris[i * 3 + 1]],
			_container_vertices[_container_tris[i * 3 + 2]],
		]

		# The vertices should be in space local to this sprite, and with y
		# coordinates inverted (so +y is up).
		for j in range(len(vertices)):
			vertices[j] = to_global(vertices[j]) - global_position
			vertices[j].y = -vertices[j].y

		vertices.sort_custom(func(a: Vector2, b: Vector2) -> bool: return a.y < b.y)

		var h_tot: float = vertices[2].y - vertices[0].y

		# This triangle is flat, so it has no area and can be ignored.
		if h_tot < tolerance:
			continue

		var y_0 := vertices[0].y
		var y_1 := vertices[1].y
		var y_2 := vertices[2].y

		# Heights of bottom and top triangles, respectively.
		var h_0 := y_1 - y_0
		var h_1 := y_2 - y_1

		# Width of the cut.
		var w: float = abs(vertices[1].x - lerp(vertices[0].x, vertices[2].x, h_0 / h_tot))

		if h_0 >= tolerance:
			var equ := QuadraticEquation.new(w / (2 * h_0), -w * y_0 / h_0,
				w * y_0 * y_0 / (2 * h_0))
			cut_tris.append([y_0, y_1, equ])
		if h_1 >= tolerance:
			var equ := QuadraticEquation.new(-w / (2 * h_1), w / 2 * (1.0 + (y_1 + y_2) / h_1),
				-w / 2 * y_1 * (1.0 + y_2 / h_1))
			cut_tris.append([y_1, y_2, equ])

	# Spots where triangles start and stop. In the form `[cut_tris_index,
	# is_end]`, where `cut_tris_index` is the index of the triangle in
	# `cut_tris`, and `is_end` is whether this is the top (end) of the
	# triangle.
	var tri_change_locs: Array[Array] = []

	for i in len(cut_tris):
		tri_change_locs.append_array([[i, false], [i, true]])

	var get_change_pos := func(a: Array) -> float:
		return cut_tris[a[0]][1 if a[1] else 0]

	tri_change_locs.sort_custom(func(a: Array, b: Array) -> bool:
		return get_change_pos.call(a) < get_change_pos.call(b))

	_area_intervals.clear()
	if len(tri_change_locs) == 0: return

	var active_equation := QuadraticEquation.new()
	var cur_area := 0.0
	var cur_y: float = get_change_pos.call(tri_change_locs.front())

	for l in tri_change_locs:
		var tri_index: int = l[0]
		var is_end: bool = l[1]
		var change_pos: float = get_change_pos.call(l)
		var tri_equation: QuadraticEquation = cut_tris[tri_index][2]

		# If multiple triangles are lined up at the same spot, we want to
		# combine all of those into the start of the same change interval. So
		# when we move far enough to get a "new triangle", we want to add the combined interval.
		if change_pos - cur_y >= tolerance:
			var interval_area := active_equation.apply(change_pos) - active_equation.apply(cur_y)
			var equ := active_equation.duplicate()
			equ.c += cur_area

			_area_intervals.append(AreaInterval.new(cur_area, cur_area + interval_area,
				cur_y, change_pos, equ))

			cur_area += interval_area
			cur_y = change_pos

		if is_end:
			active_equation.a -= tri_equation.a
			active_equation.b -= tri_equation.b
			active_equation.c -= tri_equation.c
		else:
			active_equation.a += tri_equation.a
			active_equation.b += tri_equation.b
			active_equation.c += tri_equation.c

# Based on the cached area intervals for the current direction, get the
# distance upward from the center that the liquid should reach.
func _get_depth_for_area(area: float) -> float:
	# An empty container should never be drawn.
	if not _area_intervals or area < 0.01: return -INF

	var bsearch_key := func(a: AreaInterval, b: AreaInterval) -> bool:
		return a.high_area < b.high_area

	# The types have to be the same for `bsearch_custom`.
	var dummy_interval := AreaInterval.new(area, area, 0, 0, QuadraticEquation.new())
	var i := _area_intervals.bsearch_custom(dummy_interval, bsearch_key)

	if i >= len(_area_intervals): return _area_intervals.back().high_depth

	var ai := _area_intervals[i]
	var depth := ai.area_equation.solve_in_range(area, ai.low_depth, ai.high_depth)

	# An equation might return NaN if the region containing this area, in which
	# case we just want the liquid to go up to the bottom of the region.
	return ai.low_depth if is_nan(depth) else depth
