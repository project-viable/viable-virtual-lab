class_name SelectableAreaComponent
extends InteractableComponent
## Similar to a [SelectableComponent], but instead imbues an [Area2D] with the power of being
## clicked.


signal pressed()
signal started_holding()
signal stopped_holding()


## Area that can be clicked. If not set, then this will automatically be set to the first [Area2D]
## child of this component.
@export var click_area: Area2D
@export var prompt: String = "Activate"


var _is_moused_over: bool = false


func _ready() -> void:
	if not click_area:
		click_area = Util.find_child_of_type(self, Area2D)

	if click_area:
		# Interaction layer to detect the cursor area.
		click_area.collision_mask = 0b100
		click_area.area_entered.connect(_on_click_area_area_entered)
		click_area.area_exited.connect(_on_click_area_area_exited)

func is_hovered() -> bool: return _is_moused_over
func get_absolute_z_index() -> int: return Util.get_absolute_z_index(click_area)

func get_interactions() -> Array[InteractInfo]:
	return [InteractInfo.new(InteractInfo.Kind.PRIMARY, prompt)]

func start_interact(_k: InteractInfo.Kind) -> void:
	pressed.emit()
	started_holding.emit()

func stop_interact(_k: InteractInfo.Kind) -> void:
	stopped_holding.emit()

func _on_click_area_area_entered(area: Area2D) -> void:
	if area == Game.cursor_area:
		_is_moused_over = true

func _on_click_area_area_exited(area: Area2D) -> void:
	if area == Game.cursor_area:
		_is_moused_over = false
