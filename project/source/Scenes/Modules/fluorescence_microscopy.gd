extends Node2D

func _on_microscope_mount_slide(slide: DraggableMicroscopeSlide) -> void:
	if slide:
		$Computer.current_slide = slide
	else:
		$Computer.current_slide = null
