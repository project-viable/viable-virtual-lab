extends LabBody


var _num_in_purview: int = 0


func _on_exclusive_area_2d_object_entered_purview(object: ExclusiveObjectHitbox) -> void:
	_num_in_purview += 1
	if _num_in_purview == 1:
		$AnimationPlayer.play("pipette_zoom")

func _on_exclusive_area_2d_object_left_purview(object: ExclusiveObjectHitbox) -> void:
	_num_in_purview -= 1
	if _num_in_purview == 0:
		$AnimationPlayer.play_backwards("pipette_zoom")
