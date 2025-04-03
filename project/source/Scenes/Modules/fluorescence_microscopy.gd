extends Node2D



func _on_computer_screen_click_signal() -> void:
	get_node("Computer/PopupControl").visible = true
	
func _on_change_slides(slide: String) -> void:
	$Computer.current_slide = slide
