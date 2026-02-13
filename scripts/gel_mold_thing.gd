extends Node2D


func _on_attachment_interactable_area_object_placed(body: LabBody) -> void:
	if body is GelTray: body.is_sealed = true

func _on_attachment_interactable_area_object_removed(body: LabBody) -> void:
	if body is GelTray: body.is_sealed = false
