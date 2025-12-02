extends InteractableArea
class_name ContainerInteractableArea
## Provides access to a [ContainerComponent], allowing [UseComponent]s to add or take substances.
##
## Generally speaking, a [ContainerInteractableArea] should be put into groups to specify what
## operations can be performed on it. For example, it should be put into the
## [code]container:pour[/code] group if it can be poured into, and it should be put into the
## [code]container:scoop[/code] group if it can be poured into and scooped from using the scoopula.


## An object may have multiple ContainerComponents that should not be poured into.
## For example, a gel well. This allows you to specifically choose which [ContainerComponent]
## should recieve poured contents.
@export var container_component: ContainerComponent

## This will be highlighted when the object is hovered. If this is not set, it will automatically
## be set via [method Util.try_get_best_selectable_canvas_group].
@export var interact_canvas_group: SelectableCanvasGroup


func _ready() -> void:
	super()
	if not interact_canvas_group:
		interact_canvas_group = Util.try_get_best_selectable_canvas_group(self)

func start_targeting(k: InteractInfo.Kind) -> void:
	if k == InteractInfo.Kind.SECONDARY and interact_canvas_group:
		interact_canvas_group.is_outlined = true

func stop_targeting(k: InteractInfo.Kind) -> void:
	if k == InteractInfo.Kind.SECONDARY and interact_canvas_group:
		interact_canvas_group.is_outlined = false
