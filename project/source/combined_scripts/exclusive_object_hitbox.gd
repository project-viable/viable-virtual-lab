class_name ExclusiveObjectHitbox
extends Area2D
## An area marking the boundary of an object that can interact with an [ExclusiveArea2D].


signal entered_purview_of(area: ExclusiveArea2D)
signal left_purview_of(area: ExclusiveArea2D)


var _area_stack: Array[ExclusiveArea2D] = []


func enter_area(area: ExclusiveArea2D) -> void:
	var prev_area := get_current_area()
	# We can't enter an area while we're already in it.
	if not _area_stack.has(area):
		_area_stack.push_back(area)
	_update_purview(prev_area)

func leave_area(area: ExclusiveArea2D) -> void:
	var prev_area := get_current_area()
	_area_stack.erase(area)
	_update_purview(prev_area)

func get_current_area() -> ExclusiveArea2D:
	if _area_stack: return _area_stack.back()
	else: return null

func _update_purview(prev_area: ExclusiveArea2D) -> void:
	var cur_area := get_current_area()
	if prev_area != cur_area:
		if prev_area:
			prev_area.object_leave_purview(self)
			left_purview_of.emit(prev_area)
		if cur_area:
			cur_area.object_enter_purview(self)
			entered_purview_of.emit(cur_area)

