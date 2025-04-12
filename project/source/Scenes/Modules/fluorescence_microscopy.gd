extends Node2D



func _on_computer_screen_click_signal() -> void:
	get_node("Computer/PopupControl").visible = true
	
func _on_change_slides(slide: String) -> void:
	$Computer.current_slide = slide


func _on_microscope_mount_slide(slide: DraggableMicroscopeSlide) -> void:
	if slide:
		$Computer.current_slide = slide.slide_name
	else:
		$Computer.current_slide = ""
