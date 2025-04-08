extends Node2D
signal mount_slide(slide: String)



func _on_microscope_slide_tray_mount_slide(slide: String) -> void:
	mount_slide.emit(slide)
