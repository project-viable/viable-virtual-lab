## An area that can be interacted with by dragging an object on top of it.
class_name InteractableArea
extends Area2D


func _ready() -> void:
	collision_mask = 0b10
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

## (virtual) get the possible interactions. This will only be checked if the user is currently
## dragging an object in this area.
func get_interactions() -> Array[InteractInfo]: return []

## (virtual) start performing an interaction of kind `kind`. If the interaction should happen
## immediately when the button is pressed, then that should be handled here.
func start_interact(_kind: InteractInfo.Kind) -> void: pass

## (virtual) stop performing an interaction of kind `kind`.
func stop_interact(_kind: InteractInfo.Kind) -> void: pass

## (virtual) called when this `InteractableArea` becomes the active target for the interaction of
## kind `kind`.
func start_targeting(_kind: InteractInfo.Kind) -> void: pass

## (virtual) called when this `InteractableArea` is no longer the active target for the `kind`
## interaction.
func stop_targeting(_kind: InteractInfo.Kind) -> void: pass

func _on_body_entered(body: Node2D) -> void:
	if Interaction.active_drag_component and body == Interaction.active_drag_component.body \
			and not body.is_ancestor_of(self):
		Interaction.on_interaction_area_entered(self)

func _on_body_exited(_body: Node2D) -> void:
	Interaction.on_interaction_area_exited(self)
