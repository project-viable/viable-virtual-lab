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
@export var interact_info: InteractInfo = InteractInfo.new(InteractInfo.Kind.PRIMARY, "Activate")


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
	return [interact_info]

func start_interact(_k: InteractInfo.Kind) -> void:
	_press()
	_start_holding()
	pressed.emit()
	started_holding.emit()

func stop_interact(_k: InteractInfo.Kind) -> void:
	_stop_holding()
	stopped_holding.emit()

## (virtual) Called on button down.
func _press() -> void: pass
## (virtual) Same as [method _press].
func _start_holding() -> void: pass
## (virtual) Called on button up.
func _stop_holding() -> void: pass

func _on_click_area_area_entered(area: Area2D) -> void:
	if area == Game.cursor_area:
		_is_moused_over = true

func _on_click_area_area_exited(area: Area2D) -> void:
	if area == Game.cursor_area:
		_is_moused_over = false
