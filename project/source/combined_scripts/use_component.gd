## Can be attached as a child of a draggable `LabBody` to add interactions that can be performed
## while holding the object.
class_name UseComponent
extends Node2D


## When set to false, this component will be ignored as a potential source of interactions.
@export var enable_interaction: bool = true


## (virtual) get the interactions that this component can currently do on the interactable area
## `area`. If the parent object of this isn't currently overlapping any `InteractableArea`s, then
## `area` will be null. This allows 
func get_interactions(_area: InteractableArea) -> Array[InteractInfo]: return []

## (virtual) called when this component starts being the active interactor for the `kind` input
## targeting the (possibly null) interactable area `area`.
func start_targeting(_area: InteractableArea, _kind: InteractInfo.Kind) -> void: pass

## (virtual) called when this component stops being the active interactor for the `kind` input
## targeting the (possibly null) interactable area `area`.
func stop_targeting(_area: InteractableArea, _kind: InteractInfo.Kind) -> void: pass

## (virtual) called when the user presses down the input for the interaction of kind `kind` while
## targeting the interactable area `area`.
func start_use(_area: InteractableArea, _kind: InteractInfo.Kind) -> void: pass

## (virtual) called when the user releases the input for the interaction of kind `kind` while
## targeting the interactable area `area`.
func stop_use(_area: InteractableArea, _kind: InteractInfo.Kind) -> void: pass
