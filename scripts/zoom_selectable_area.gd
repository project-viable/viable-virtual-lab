class_name ZoomSelectableArea
extends SelectableAreaComponent
## Allows the user to press the inspect button when hovering to zoom in on a set of objects.
##
## Note: If [member interact_info] does not use [const InteractInfo.Kind.INSPECT], then it will be
## replaced with a generic zoom interact info.


signal zoomed_in()
signal zoomed_out()


## Provides the region that will be zoomed in on. If not set, this will automatically be set to the
## first [RegionProvider] child of this node.
@export var region_provider: RegionProvider
## If set, zooming in will also display the contents of this subscene camera.
@export var subscene_camera: SubsceneCamera


var _is_zoomed_in := false


func _ready() -> void:
	super()
	if not region_provider: region_provider = Util.find_child_of_type(self, RegionProvider)
	if interact_info.kind != InteractInfo.Kind.INSPECT:
		interact_info = InteractInfo.new(InteractInfo.Kind.INSPECT, "Zoom in")
	Game.main.camera_focus_owner_changed.connect(_on_main_camera_focus_owner_changed)


func _press() -> void:
	if not region_provider: return
	var zoom_rect := region_provider.get_region()
	if not zoom_rect.has_area(): return

	if subscene_camera:
		Game.main.focus_camera_and_show_subscene(zoom_rect, subscene_camera)
	else:
		Game.main.focus_camera_on_rect(zoom_rect)
	Game.main.set_camera_focus_owner(self)
	_is_zoomed_in = true
	enable_interaction = false
	zoomed_in.emit()

func is_zoomed_in() -> bool: return _is_zoomed_in

func _on_main_camera_focus_owner_changed(focus_owner: Node) -> void:
	if _is_zoomed_in and focus_owner != self:
		_is_zoomed_in = false
		zoomed_out.emit()
		enable_interaction = true
