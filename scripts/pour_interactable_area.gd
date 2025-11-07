extends InteractableArea
class_name PourInteractableArea
## Should be attached to objects that can have something be poured into it.

## An object may have multiple ContainerComponents that should not be poured into.
## For example, a gel well. This allows you to specifically choose which [ContainerComponent]
## should recieve poured contents.
@export var container_component: ContainerComponent
