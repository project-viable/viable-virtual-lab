class_name InteractableSystem
extends Node2D
## Allows interaction keybindings to be available whether or not something is being held.
## [InteractionSystem] interactions take lower priority than any other interactable.


@export var enable_interaction: bool = true


func _enter_tree() -> void:
	add_to_group(&"interactable_system")

func get_interactions() -> Array[InteractInfo]: return []

func start_targeting(_kind: InteractInfo.Kind) -> void: pass
func stop_targeting(_kind: InteractInfo.Kind) -> void: pass

func start_interact(_kind: InteractInfo.Kind) -> void: pass
func stop_interact(_kind: InteractInfo.Kind) -> void: pass
