extends LabBody
class_name Pipe #TODO: Placeholder name since Pipette is already used in the old simulation


const PLUNGER_OFFSETS: Array[float] = [0, 8, 10]
const PLUNGE_VOLUME: float = 0.1
const PLUNGE_DOWN_TIME: float = 0.3
const PLUNGE_UP_TIME: float = 0.2
const VOLUME_PER_DIST: float = PLUNGE_VOLUME / PLUNGER_OFFSETS[2]
# Slightly less is pushed out than pulled to require the second stop.
const PLUNGE_DOWN_VOLUME_RATIO: float = 0.98


@export var is_tip_contaminated: bool = false
@export var has_tip: bool = false:
	set(value):
		has_tip = value
		$SelectableCanvasGroup/PipetteWithTip.visible = has_tip
		$SelectableCanvasGroup/SubstanceDisplayPolygon.visible = has_tip
		$TipCollision.disabled = not has_tip

		$%SubsceneTip.visible = has_tip
		$%SubsceneTipCollision.disabled = not has_tip
		$%SubsceneSubstanceDisplay.visible = has_tip

		$ExclusiveObjectHitbox/NoTipEnd.disabled = has_tip
		$ExclusiveObjectHitbox/WithTipEnd.disabled = not has_tip

@onready var _orig_plunger_pos: float = $%Plunger.position.y
@onready var _orig_sub_pipette_pos: Vector2 = $%SubscenePipette.position
var _cur_subscene_camera: SubsceneCamera = null
var _mouse_movement := Vector2.ZERO
var _mouse_pos_before_zoom := Vector2.ZERO


func _input(e: InputEvent) -> void:
	if e is InputEventMouseMotion:
		_mouse_movement += e.relative

func _process(_delta: float) -> void:
	# Stop looking at the subscene if the pipette has been removed.
	if _cur_subscene_camera and not Util.get_camera_world_rect(_cur_subscene_camera).has_point($%SubsceneTipOpeningArea.global_position):
		_leave_subscene()

func _physics_process(delta: float) -> void:
	super(delta)

	# Handle movement with subscene
	if _cur_subscene_camera:
		$%SubscenePipette.move_and_collide(_mouse_movement)

	_mouse_movement = Vector2.ZERO

	var cur_offset: float = $%Plunger.position.y - _orig_plunger_pos
	var dest_offset := PLUNGER_OFFSETS[$UseComponent.stop]

	var plunge_diff: float = sign(dest_offset - cur_offset) * PLUNGER_OFFSETS[2] * delta

	if plunge_diff < 0:
		plunge_diff /= PLUNGE_UP_TIME
		plunge_diff = max(cur_offset + plunge_diff, 0) - cur_offset
	elif plunge_diff > 0:
		plunge_diff /= PLUNGE_DOWN_TIME
		plunge_diff = min(cur_offset + plunge_diff, dest_offset) - cur_offset
	$%Plunger.position.y += plunge_diff

	var substance_display: SubstanceDisplayPolygon = null
	# If we are zoomed in with a subscene, we want to pipette into the subscene instead.
	if _cur_subscene_camera:
		for a: Area2D in $%SubsceneTipOpeningArea.get_overlapping_areas():
			if a is SubstanceAccessArea:
				substance_display = a.substance_display
				break
	else:
		for a: Area2D in $TipOpeningArea.get_overlapping_areas():
			if a is SubstanceAccessArea:
				substance_display = a.substance_display
				break

	if substance_display and has_tip:
		var tip_node: Node2D = $%SubsceneTipOpeningArea if _cur_subscene_camera else $TipOpeningArea
		# Only pull if we're below the fluid level.
		if plunge_diff < -0.001 and substance_display.global_fluid_top_y_coord <= tip_node.global_position.y:
			var volume: float = -plunge_diff * VOLUME_PER_DIST
			$ContainerComponent.add(substance_display.source.take_volume(volume))
		elif plunge_diff > 0.001:
			var volume: float = plunge_diff * VOLUME_PER_DIST * PLUNGE_DOWN_VOLUME_RATIO
			substance_display.source.add($ContainerComponent.take_volume(volume))

func _on_exclusive_object_hitbox_entered_purview_of(area: ExclusiveArea2D) -> void:
	collision_mask |= 0b1000
	DepthManager.stop_managing(self)
	z_index = DepthManager.get_base_z_index(Util.get_absolute_z_index(area))

	var object_to_zoom := area.get_parent() as CollisionObject2D
	if object_to_zoom and is_active():
		# Zoom in on the object, with extra room above it for this pipette.
		var rect := Util.get_global_bounding_box(object_to_zoom).grow_side(1, Util.get_global_bounding_box(self).size.y + 5)
		
		if area is SubsceneExclusiveArea:
			_cur_subscene_camera = area.camera
			disable_follow_cursor = true
			disable_drop = true
			Game.main.focus_camera_and_show_subscene(rect, _cur_subscene_camera, true, 1.5)
			$%SubscenePipette.global_position = area.entry_node.global_position - $%SubsceneTipOpeningArea.position
			_mouse_pos_before_zoom = Cursor.virtual_mouse_position
		else:
			Game.main.focus_camera_on_rect(rect, 1.5)

func _on_exclusive_object_hitbox_left_purview_of(area: ExclusiveArea2D) -> void:
	collision_mask &= ~0b1000
	if is_active():
		DepthManager.move_to_front_of_layer(self, DepthManager.Layer.HELD)
	else:
		DepthManager.move_to_front_of_layer(self, depth_layer_to_drop_in)

	_leave_subscene()
	Game.camera.return_to_main_scene(1.5)

func _leave_subscene() -> void:
	if _cur_subscene_camera:
		Game.main.hide_subscene()
		disable_follow_cursor = false
		disable_drop = false
		$%SubscenePipette.position = _orig_sub_pipette_pos
		Cursor.virtual_mouse_position = _mouse_pos_before_zoom
		_cur_subscene_camera = null
