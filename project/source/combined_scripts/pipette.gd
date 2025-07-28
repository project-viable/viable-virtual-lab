extends LabBody
class_name Pipe # TODO: Since the old sinmulaton uses a class_name Pipette already, had to change the name. Should name it Pipette when the old stuff is gone

var has_tip: bool = false:
	set(value):
		has_tip = value
		
		# Change sprites and active collision depending if it has_tip is true or false
		$CollisionPolygon2DNoTip.disabled = value
		$SelectableCanvasGroup/PipetteNoTip.visible = !value
		
		$CollisionPolygon2DWithTip.disabled = !value
		$SelectableCanvasGroup/PipetteWithTip.visible = value
