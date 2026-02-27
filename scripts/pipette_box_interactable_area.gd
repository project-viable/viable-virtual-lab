extends InteractableArea

var _info: InteractInfo = InteractInfo.new(InteractInfo.Kind.PRIMARY, "Add Tip")
var _disallowed_info: InteractInfo = InteractInfo.new(InteractInfo.Kind.PRIMARY, "Add Tip (Pipette already has a tip)", false)
var _interact_canvas_group: SelectableCanvasGroup


func _ready() -> void:
	super()
	_interact_canvas_group = Util.try_get_best_selectable_canvas_group(self)

func get_interactions() -> Array[InteractInfo]:
	if Interaction.held_body is Pipette:
		if Interaction.held_body.has_tip: return [_disallowed_info]
		else: return [_info]

	return []

func start_interact(_kind: InteractInfo.Kind) -> void:
	var pipette: Pipette = Interaction.held_body
	pipette.has_tip = true

func start_targeting(_kind: InteractInfo.Kind) -> void:
	if _interact_canvas_group: _interact_canvas_group.is_outlined = true
func stop_targeting(_kind: InteractInfo.Kind) -> void:
	if _interact_canvas_group: _interact_canvas_group.is_outlined = false
