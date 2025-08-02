extends LabBody
class_name Pipe #TODO: Placeholder name since Pipette is already used in the old simulation

var has_tip: bool = false:
	set(value):
		has_tip = value
		$SelectableCanvasGroup/PipetteWithTip.visible = has_tip
