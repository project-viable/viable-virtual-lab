extends Node2D
signal mount_slide(slide: String)

# Slide is on top of the opening
func _on_microscope_slide_tray_mount_slide(slide: String) -> void:
	mount_slide.emit(slide)
