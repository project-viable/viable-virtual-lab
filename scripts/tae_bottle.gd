extends LabBody


var _num_pipettes: int = 0


func _on_exclusive_area_2d_object_entered_purview(_object: ExclusiveObjectHitbox) -> void:
	_num_pipettes += 1
	if _num_pipettes == 1:
		$AnimationPlayer.play("fade_front")

func _on_exclusive_area_2d_object_left_purview(_object: ExclusiveObjectHitbox) -> void:
	_num_pipettes -= 1
	if _num_pipettes == 0:
		$AnimationPlayer.play_backwards("fade_front")

func _on_pour_use_component_started_pouring() -> void:
	$AnimationPlayer.play("fade_front")

func _on_pour_use_component_stopped_pouring() -> void:
	$AnimationPlayer.play_backwards("fade_front")
