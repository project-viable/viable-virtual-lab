extends Node2D
signal mount_slide(slide: DraggableMicroscopeSlide)

# Slide is on top of the opening
func _on_microscope_slide_tray_mount_slide(slide: DraggableMicroscopeSlide) -> void:
	if slide == null:
		mount_slide.emit(slide)
	else:
		mount_slide.emit(slide)
