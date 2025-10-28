extends LabBody
class_name Pipe #TODO: Placeholder name since Pipette is already used in the old simulation


const PLUNGER_OFFSET: float = 10
const PLUNGE_VOLUME: float = 0.1
const PLUNGE_TIME: float = 0.7


@export var is_tip_contaminated: bool = false
@export var has_tip: bool = false:
	set(value):
		has_tip = value
		$SelectableCanvasGroup/PipetteWithTip.visible = has_tip
		$SelectableCanvasGroup/SubstanceDisplayPolygon.visible = has_tip
		$TipCollision.disabled = not has_tip
		$ExclusiveObjectHitbox/NoTipEnd.disabled = has_tip
		$ExclusiveObjectHitbox/WithTipEnd.disabled = not has_tip


func _physics_process(delta: float) -> void:
	super(delta)
	

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
