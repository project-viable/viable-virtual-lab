extends LabBody
class_name Pipe #TODO: Placeholder name since Pipette is already used in the old simulation


@export var is_tip_contaminated: bool = false
@export var has_tip: bool = false:
	set(value):
		has_tip = value
		$SelectableCanvasGroup/PipetteWithTip.visible = has_tip
		$TipCollision.disabled = not has_tip
