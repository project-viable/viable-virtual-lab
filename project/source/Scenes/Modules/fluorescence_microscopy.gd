extends Node2D



func _on_computer_screen_click_signal() -> void:
	get_node("Computer/PopupControl").visible = true
	

func _on_microscope_mount_slide(slide: DraggableMicroscopeSlide) -> void:
	if slide and slide.slide_orientation_up:
		$Computer.current_slide = slide.slide_name
	else:
		$Computer.current_slide = ""
