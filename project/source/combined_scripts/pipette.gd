extends LabBody
class_name Pipe #TODO: Placeholder name since Pipette is already used in the old simulation


@export var is_tip_contaminated: bool = false
@export var has_tip: bool = false:
	set(value):
		has_tip = value
		$SelectableCanvasGroup/PipetteWithTip.visible = has_tip
		$Subscene/CharacterBody2D/PipetteTip.visible = has_tip
		$Subscene/CharacterBody2D/TipCollision.disabled = not has_tip
		$TipCollision.disabled = not has_tip


var _subscene_velocity: Vector2 = Vector2.ZERO


func _ready() -> void:
	super()
	has_tip = false

func _unhandled_input(event: InputEvent) -> void:
	if $UseComponent.containing_subscene and event is InputEventMouseMotion:
		_subscene_velocity += event.screen_velocity

func _physics_process(delta: float) -> void:
	follow_cursor = $UseComponent.containing_subscene == null
	super(delta)

	if $UseComponent.containing_subscene:
		$Subscene/CharacterBody2D.velocity = _subscene_velocity
		$Subscene/CharacterBody2D.move_and_slide()
		_subscene_velocity = Vector2.ZERO

func _on_use_component_volume_changed() -> void:
	var rep := "%03d" % [$UseComponent.volume]

	$Panel/Label.text = rep[0]
	$Panel/Label2.text = rep[1]
	$Panel/Label3.text = rep[2]
	
	$Panel.show()
	$PopupTimer.start(0.5)

func _on_popup_timer_timeout() -> void:
	$Panel.hide()
