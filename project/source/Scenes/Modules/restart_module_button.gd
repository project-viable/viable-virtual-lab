extends Node2D


func _on_restart_module_button_pressed() -> void:
	# looks gross... does the job
	var menu: Node = $"../../../../../Menu"
	if menu.current_module != null:
		menu.module_selected(menu.current_module)
