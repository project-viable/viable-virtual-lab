extends Node2D

func _on_exit_module_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Main.tscn") 
