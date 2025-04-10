extends PanelContainer

# Check for when the slides are dragged out of the fridge or into it

func _on_area_2d_body_entered(body: CharacterBody2D) -> void:
	body.is_inside_fridge = true

func _on_area_2d_body_exited(body: CharacterBody2D) -> void:
	body.is_inside_fridge = false
	
