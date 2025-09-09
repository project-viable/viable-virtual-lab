extends LabBody
class_name Pipe #TODO: Placeholder name since Pipette is already used in the old simulation


@export var is_tip_contaminated: bool = false
@export var has_tip: bool = false:
	set(value):
		has_tip = value
		$SelectableCanvasGroup/PipetteWithTip.visible = has_tip
		$TipCollision.disabled = not has_tip

func _on_use_component_volume_changed() -> void:
	var rep := "%03d" % [$UseComponent.volume]

	$Panel/Label.text = rep[0]
	$Panel/Label2.text = rep[1]
	$Panel/Label3.text = rep[2]
	
	$Panel.show()
	$PopupTimer.start(0.5)

func _on_popup_timer_timeout() -> void:
	$Panel.hide()

func _process(_delta: float) -> void:
	$ZoomPanelContainer.hide()
	for b: Node2D in $Area2D.get_overlapping_bodies():
		if b is GelMold:
			$ZoomPanelContainer.show()
