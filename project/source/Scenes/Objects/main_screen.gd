extends Node2D

func _on_app_icon_pressed() -> void:
	$Desktop.visible = false
	$Desktop/AppIcon.visible = false
	$ContentScreen.show()
