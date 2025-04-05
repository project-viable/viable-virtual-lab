extends PanelContainer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_2d_body_entered(body: CharacterBody2D) -> void:
	body.is_inside_fridge = true

func _on_area_2d_body_exited(body: CharacterBody2D) -> void:
	body.is_inside_fridge = false
	
