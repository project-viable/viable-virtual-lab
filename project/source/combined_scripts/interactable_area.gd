## An area that can be interacted with by dragging an object on top of it.
class_name InteractableArea
extends Area2D


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
	if body == Interaction.held_drag_component.body:
		Interaction.on_interaction_area_entered(self)

func _on_body_exited(body: Node2D) -> void:
	Interaction.on_interaction_area_exited(self)
