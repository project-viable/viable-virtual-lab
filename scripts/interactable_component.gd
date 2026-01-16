## A component that can be interacted with directly when the user isn't holding something, 
## typically represented as a clickable sprite
class_name InteractableComponent
extends Node2D


## When set to false, this component will be ignored as a potential target of interactions.
@export var enable_interaction: bool = true


func _enter_tree() -> void:
	# Needs to be set so that the `Interaction` singleton can quickly find it.
	add_to_group(&"interactable_component")

## (virtual) return true if the user is currently "hovering" this component. For example, if this
## is associated with a sprite, then this might return true if the mouse is hovering that sprite.
## This should return true even if this is not the topmost one; the correct one will be chosen by
## `Interaction` with the help of `get_draw_order` and `get_absolute_z_index`.
func is_hovered() -> bool: return false

## (virtual) get the draw order of this component, typically obtained by a call to
## `Interaction.get_next_draw_order`.
func get_draw_order() -> int: return 0

## (virtual) get the absolute z index of this component.
func get_absolute_z_index() -> int: return 0

## (virtual) get the list of interactions that this component can perform right now.
func get_interactions() -> Array[InteractInfo]: return []

## (virtual) called when this becomes a target for an interaction of kind `kind`.
func start_targeting(_kind: InteractInfo.Kind) -> void: pass

## (virtual) called when this stops being a target for the interaction of kind `kind`.
func stop_targeting(_kind: InteractInfo.Kind) -> void: pass

## (virtual) called when the user starts performing an interaction of kind `kind` targeted at this
## component.
func start_interact(_kind: InteractInfo.Kind) -> void: pass

## (virtual) called when the user stops performing an interaction of kind `kind` targeted at this
## component.
func stop_interact(_kind: InteractInfo.Kind) -> void: pass
