extends LabBody
class_name Pipe #TODO: Placeholder name since Pipette is already used in the old simulation


const PLUNGER_OFFSET: float = 10
const PLUNGE_VOLUME: float = 0.1
const PLUNGE_DOWN_TIME: float = 0.3
const PLUNGE_UP_TIME: float = 0.2
const VOLUME_PER_DIST: float = PLUNGE_VOLUME / PLUNGER_OFFSET


@export var is_tip_contaminated: bool = false
@export var has_tip: bool = false:
	set(value):
		has_tip = value
		$SelectableCanvasGroup/PipetteWithTip.visible = has_tip
		$SelectableCanvasGroup/SubstanceDisplayPolygon.visible = has_tip
		$TipCollision.disabled = not has_tip
		$ExclusiveObjectHitbox/NoTipEnd.disabled = has_tip
		$ExclusiveObjectHitbox/WithTipEnd.disabled = not has_tip

@onready var _orig_plunger_pos: float = $%Plunger.position.y


func _physics_process(delta: float) -> void:
	super(delta)
	var plunge_diff: float = 0
	# Very very lazy way to do this. This should use the interaction system.
	if Input.is_action_pressed("interact_secondary"):
		plunge_diff = PLUNGER_OFFSET / PLUNGE_DOWN_TIME * delta
	else:
		plunge_diff = -PLUNGER_OFFSET / PLUNGE_UP_TIME * delta

	plunge_diff = clamp($%Plunger.position.y + plunge_diff, _orig_plunger_pos, _orig_plunger_pos + PLUNGER_OFFSET) - $%Plunger.position.y
	$%Plunger.position.y += plunge_diff

	var substance_display: SubstanceDisplayPolygon = null
	for a: Area2D in $TipOpeningArea.get_overlapping_areas():
		if a is SubstanceAccessArea:
			substance_display = a.substance_display
			break

	if substance_display and has_tip:
		# Only pull if we're below the fluid level.
		if plunge_diff < -0.001 and substance_display.global_fluid_top_y_coord > $TipOpeningArea.global_position.y:
			var volume: float = -plunge_diff * VOLUME_PER_DIST
			$ContainerComponent.add(substance_display.source.take_volume(volume))
		elif plunge_diff > 0.001:
			var volume: float = plunge_diff * VOLUME_PER_DIST
			substance_display.source.add($ContainerComponent.take_volume(volume))

func _on_exclusive_object_hitbox_entered_purview_of(area: ExclusiveArea2D) -> void:
	collision_mask |= 0b1000
	z_index = -1
	var object_to_zoom := area.get_parent() as CollisionObject2D
	if object_to_zoom and is_active():
		# Zoom in on the object, with extra room above it for this pipette.
		var rect := Util.get_global_bounding_box(object_to_zoom).grow_side(1, Util.get_global_bounding_box(self).size.y + 5)
		Game.main.focus_camera_on_rect(rect, 1.5)

func _on_exclusive_object_hitbox_left_purview_of(area: ExclusiveArea2D) -> void:
	collision_mask &= ~0b1000
	z_index = 0
	Game.camera.return_to_main_scene(1.5)
