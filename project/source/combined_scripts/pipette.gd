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
var _prev_stop: int = 0
var _stop_volumes: Array[float] = [0.0, 0.005, 0.006]


func _ready() -> void:
	super()
	has_tip = false

func _unhandled_input(event: InputEvent) -> void:
	if $UseComponent.containing_subscene and event is InputEventMouseMotion:
		_subscene_velocity += event.screen_velocity

func _physics_process(delta: float) -> void:
	follow_cursor = $UseComponent.containing_subscene == null
	enable_interaction = follow_cursor
	super(delta)

	if $UseComponent.containing_subscene:
		$Subscene/CharacterBody2D.velocity = _subscene_velocity / 3
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

func _get_target_container() -> ContainerComponent:
	for a: Area2D in $%TipArea.get_overlapping_areas():
		if a is SubsceneSubstanceArea:
			print("Found %s" % [a])
		if a is SubsceneSubstanceArea and a.container:
			return a.container
	return null

func _on_use_component_stop_changed(stop: int) -> void:
	if stop == _prev_stop or not has_tip: return
	var vol_diff := _stop_volumes[stop] - _stop_volumes[_prev_stop]
	_prev_stop = stop
	var container := _get_target_container()

	if vol_diff > 0.0:
		# Push out slightly less than you take in to require the purge.
		var substance: SubstanceInstance = $ContainerComponent.take_volume(vol_diff * 0.95)
		if container:
			container.add(substance)
			print("Putting %s into %s" % [vol_diff * 0.95, container])
	elif container:
		$ContainerComponent.add(container.take_volume(-vol_diff))
		print("Taking %s from %s" % [vol_diff, container])
