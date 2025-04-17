extends Node2D

func _on_microscope_mount_slide(slide: DraggableMicroscopeSlide) -> void:
	if slide and slide.slide_orientation_up:
		$Computer.current_slide = slide.slide_name
	else:
		$Computer.current_slide = ""
