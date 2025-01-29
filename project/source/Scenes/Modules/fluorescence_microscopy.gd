extends Node2D

func _on_computer_screen_click_signal() -> void:
	print("received")
	var tween: Tween = get_tree().create_tween()
	tween.tween_property($Camera2D, "zoom", Vector2(3.0, 3.0), 1)
	tween.parallel().tween_property($Camera2D, "position", $Computer.global_position, 1)
