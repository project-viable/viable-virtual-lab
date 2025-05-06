extends Node2D

func _on_app_icon_pressed() -> void:
	LabLog.log("Clicked on app icon", true, false)
	$Desktop.visible = false
	$Desktop/AppIcon.visible = false
	$ContentScreen.show()
