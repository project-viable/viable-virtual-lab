## Imbues a `SelectableCanvasGroup` with the power of being clicked.
class_name SelectableComponent
extends InteractableComponent


signal pressed()
signal started_holding()
signal stopped_holding()


## This will be outlined when it's hovered, and clicking will cause it to be held. If not set, this
## will automatically be set to the first [SelectableCanvasGroup] child of this component.
@export var interact_canvas_group: SelectableCanvasGroup
@export var interact_info: InteractInfo = InteractInfo.new(InteractInfo.Kind.PRIMARY, "Activate")


func is_hovered() -> bool: return interact_canvas_group.is_mouse_hovering()
func get_draw_order() -> int: return interact_canvas_group.draw_order_this_frame
func get_absolute_z_index() -> int: return Util.get_absolute_z_index(interact_canvas_group)

func _ready() -> void:
	if not interact_canvas_group:
		interact_canvas_group = Util.find_child_of_type(self, SelectableCanvasGroup)

func get_interactions() -> Array[InteractInfo]:
	# TODO: Use a better system instead of only having the single left-click interaction with a
	# hard-coded name.
	return [interact_info]

func start_targeting(_k: InteractInfo.Kind) -> void:
	interact_canvas_group.is_outlined = true

func stop_targeting(_k: InteractInfo.Kind) -> void:
	interact_canvas_group.is_outlined = false

func start_interact(_k: InteractInfo.Kind) -> void:
			pressed.emit()
			started_holding.emit()

func stop_interact(_k: InteractInfo.Kind) -> void:
	stopped_holding.emit()
