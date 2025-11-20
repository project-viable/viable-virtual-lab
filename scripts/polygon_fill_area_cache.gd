class_name PolygonFillAreaCache
## Caches the cumulative area of a polygon, starting at the lowest y value, up to the highest y
## value, and allows obtaining the depth of a given area.
##
## This can be used to determine the depth of fluid in a container based on the area of that fluid.

var _area_intervals: Array[AreaInterval] = []


## Get the total area of the polygon.
func get_total_area() -> float:
	if _area_intervals: return _area_intervals.back().high_area
	else: return 0

## Get the cumulative area of the polygon from the lowest y value up to the value given by
## [param y] (note that this is the y value in the polygon [i]after[/i] the [code]transform[/code]
## parameter has been applied during [method set_from_triangulated_polygon]). If the y value is
## less than the smallest y value in the polygon, then an area of zero is returned. If it is
## greater than the largest y value, then the total area is returned.
func get_area_at_y_value(y: float) -> float:
	if not _area_intervals: return 0

	var bsearch_key := func(a: AreaInterval, b: AreaInterval) -> bool:
		return a.high_depth < b.high_depth

	var dummy_interval := AreaInterval.new(0, 0, y, y, null)
	var i := _area_intervals.bsearch_custom(dummy_interval, bsearch_key)

	if i >= len(_area_intervals): return _area_intervals.back().high_area
	var ai := _area_intervals[i]

	# This will happen if the y value is smaller than the smallest y value in the polygon.
	if y < ai.low_depth: return ai.low_area
	else: return ai.area_equation.apply(y)

## If [param area] is between 0 and [code]get_total_area()[/code] (inclusive), this acts as a right
## inverse to [method get_area_at_y_value]. If [param area] is less than zero, then this function
## will return negative infinity. If it is greater than the total area, then the maximum y value is
## returned.
func get_y_value_from_area(area: float) -> float:
	# An empty container should never be drawn.
	if not _area_intervals or area < 0.01: return -INF

	var bsearch_key := func(a: AreaInterval, b: AreaInterval) -> bool:
		return a.high_area < b.high_area

	# The types have to be the same for `bsearch_custom`.
	var dummy_interval := AreaInterval.new(area, area, 0, 0, null)
	var i := _area_intervals.bsearch_custom(dummy_interval, bsearch_key)

	if i >= len(_area_intervals): return _area_intervals.back().high_depth

	var ai := _area_intervals[i]
	var depth := ai.area_equation.solve_in_range(area, ai.low_depth, ai.high_depth)

	# An equation might return NaN, in which case we just want the liquid to go up to the bottom of
	# the region.
	return ai.low_depth if is_nan(depth) else depth

## Cache the cumulative area of [param polygon], triangulated by the indices in
## [param tri_indices], which should have been obtained by a call to
## [method Geometry2D.triangulate_polygon]. Areas area calculated from the lowest to highest y
## value, [i]after[/i] [param transform] has been applied.
func set_from_triangulated_polygon(polygon: PackedVector2Array, tri_indices: PackedInt32Array,
		transform: Transform2D) -> void:
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
	for i in range(0, len(tri_indices) / 3):
		var vertices: Array[Vector2] = [
			polygon[tri_indices[i * 3]],
			polygon[tri_indices[i * 3 + 1]],
			polygon[tri_indices[i * 3 + 2]],
		]

		# The original coordinates are local to this sprite, but we want them rotated into the
		# coordinate system where `_last_cached_down_dir` is pointed down. Then we invert the y
		# coordinates so higher y coordinates go up (this is for "convenience", but might make
		# things worse, but whatever).
		for j in range(len(vertices)):
			vertices[j] = transform * vertices[j]

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

	# Equation for total area of the polygon up to a depth, given as a maximum y value.
	var area_equation: QuadraticEquation = QuadraticEquation.new()

	func _init(p_low_area: float, p_high_area: float, p_low_depth: float, p_high_depth: float,
		p_area_equation: QuadraticEquation) -> void:
		low_area = p_low_area
		high_area = p_high_area
		low_depth = p_low_depth
		high_depth = p_high_depth
		area_equation = p_area_equation


