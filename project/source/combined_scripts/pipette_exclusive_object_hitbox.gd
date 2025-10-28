extends ExclusiveObjectHitbox


func _can_enter_purview_of(area: ExclusiveArea2D) -> bool:
	return area.is_in_group(&"exclusive_area:pipette")
