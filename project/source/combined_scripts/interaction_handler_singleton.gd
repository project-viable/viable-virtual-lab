extends Node
var interactables: Array[PhysicsBody2D] = []
var interactor: RigidBody2D

func _input(event: InputEvent) -> void:
	if GameState.is_dragging:
		if event.is_action_released("click") and interactables:
			
			#var interactable: PhysicsBody2D = _get_top_most_interactable(interactables) # Get based on z_index
			var interactable: PhysicsBody2D = interactables[-1] # Get based on last area entered
			print("%s is interacting with %s" % [interactor.name, interactable.name])
			
		
			GameState.interactor = interactor
			GameState.interactable = interactable
			GameState.is_dragging = false
		
func _on_interaction_area_entered(area: Area2D, interactable: RigidBody2D) -> void:
	# Objects falling onto one another due to physics should be ignored
	if not GameState.is_dragging:
		return
		
	interactor = area.get_owner() # The object that is being dragged into the area
	interactables.append(interactable)


func _on_interaction_area_exited(area: Area2D, interactable: RigidBody2D) -> void:
	interactables.erase(interactable)

# TODO: Could be more robust
func _get_top_most_interactable(interactables: Array[PhysicsBody2D]) -> PhysicsBody2D:
	interactables.sort_custom(
		func(object_a: PhysicsBody2D, object_b: PhysicsBody2D) -> int:
			return object_a.z_index - object_b.z_index
	)
	return interactables[-1]
