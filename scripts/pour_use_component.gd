extends UseComponent
class_name PourUseComponent


## While pouring, this will be set to spill into the target container.
@export var spill_component: SpillComponent
## Body to tilt while pouring. If this is not set in the editor, then it will automatically be set
## to this component's parent node.
@export var body: LabBody
## Angle, in radians, that [member body] will be tilted to while pouring. By default, tilt to the
## left.
@export_custom(PROPERTY_HINT_NONE, "suffix:rad") var tilt_angle: float = -3 * PI / 4


func _enter_tree() -> void:
	if not body: body = get_parent() as LabBody

func get_interactions(area: InteractableArea) -> Array[InteractInfo]:
	var results: Array[InteractInfo] = []

	if area is PourInteractableArea and area.container_component and spill_component:
		results.push_back(InteractInfo.new(InteractInfo.Kind.SECONDARY, "(hold) Pour"))

	if results and not Game.main.get_camera_focus_owner():
		results.push_back(InteractInfo.new(InteractInfo.Kind.INSPECT, "Zoom in to pour"))

	return results

func start_use(area: InteractableArea, kind: InteractInfo.Kind) -> void:
	match kind:
		InteractInfo.Kind.SECONDARY:
			spill_component.target_container = area.container_component
			if body:
				body.disable_drop = true
				body.disable_rotate_upright = true
				body.global_rotation += tilt_angle

		InteractInfo.Kind.INSPECT:
			var parent_body := get_parent() as CollisionObject2D
			var area_parent_body := area.get_parent() as CollisionObject2D
			if not parent_body or not area_parent_body: return
			Game.main.focus_camera_on_rect(Util.get_global_bounding_box(parent_body).merge(Util.get_global_bounding_box(area_parent_body)))
			Game.main.set_camera_focus_owner(self)

func stop_use(_area: InteractableArea, kind: InteractInfo.Kind) -> void:
	match kind:
		InteractInfo.Kind.SECONDARY:
			spill_component.target_container = null
			if body:
				body.disable_drop = false
				body.disable_rotate_upright = false
				body.global_rotation -= tilt_angle
