extends Node2D


func _on_app_icon_app_click_signal() -> void:
	$DesktopBackground.hide()
	$AppIcon.hide()
	get_node("AppIcon").disable = true
