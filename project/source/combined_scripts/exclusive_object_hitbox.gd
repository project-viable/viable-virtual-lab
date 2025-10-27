class_name ExclusiveObjectHitbox
extends Area2D
## An area marking the boundary of an object that can interact with an [ExclusiveArea2D].


signal entered_purview_of(area: ExclusiveArea2D)
signal left_purview_of(area: ExclusiveArea2D)


var _area_stack: Array[ExclusiveArea2D] = []


func enter_area(area: ExclusiveArea2D) -> void:
	var prev_area := get_current_area()
	# We can't enter an area while we're already in it.
	if _can_enter_purview_of(area) and not _area_stack.has(area):
		_area_stack.push_back(area)
	_update_purview(prev_area)

func leave_area(area: ExclusiveArea2D) -> void:
	var prev_area := get_current_area()
	_area_stack.erase(area)
	_update_purview(prev_area)

func get_current_area() -> ExclusiveArea2D:
	if _area_stack: return _area_stack.back()
	else: return null

## (virtual) This object will only enter the purview of [param _area] if this returns
## [code]true[/code]. This can be overridden to only allow specific areas.
func _can_enter_purview_of(_area: ExclusiveArea2D) -> bool: return true
## (virtual) Called when this object enters the purview of the area [param _area]. This is always called
## [i]before[/i] [signal entered_purview_of] is emitted.
func _enter_purview_of(_area: ExclusiveArea2D) -> void: pass
## (virtual) Called when this object leaves the purview of the area [param _area]. This is called [i]after[/i]
## [signal left_purview_of] is emitted.
func _leave_purview_of(_area: ExclusiveArea2D) -> void: pass

func _update_purview(prev_area: ExclusiveArea2D) -> void:
	var cur_area := get_current_area()
	if prev_area != cur_area:
		if prev_area:
			prev_area.object_leave_purview(self)
			left_purview_of.emit(prev_area)
			_leave_purview_of(prev_area)
		if cur_area:
			_enter_purview_of(cur_area)
			cur_area.object_enter_purview(self)
			entered_purview_of.emit(cur_area)

