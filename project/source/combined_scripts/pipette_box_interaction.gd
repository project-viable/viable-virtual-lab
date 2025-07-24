extends InteractionComponent
class_name PipetteBoxInteraction

func interact(interactor: PhysicsBody2D) -> void:
	if interactor is Pipe:
		interactor.has_tip = true	
		
	else:
		print("Only Pipettes can interact with %s" % [interactable.name])
