extends LabBody
var vol_to_take: float = 0.0
func _on_interactable_area_body_entered(body: Node2D) -> void:
	#If the scoopula is dragged over a container with a substance in it, the scoopula menu will appear.
	#The scoopula menu is under a canvas layer so that it sticks to the bottom left corner of the viewport when visible

	if body is LabBody and body.find_child("ContainerComponent") and body.name != "Scoopula":
		$UseComponent/CanvasLayer/Control.visible = true
		
func _on_interactable_area_body_exited(body: Node2D) -> void:
	$UseComponent/CanvasLayer/Control.visible = false
	$UseComponent/CanvasLayer/Control/PanelContainer/VBoxContainer/sliderDispenseQty.value = 0.0
