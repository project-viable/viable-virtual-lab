extends Control

signal channel_selected(channel: String)

func _on_dapi_pressed() -> void:
	channel_selected.emit("Dapi")


func _on_fitc_pressed() -> void:
	channel_selected.emit("FITC")


func _on_ritc_pressed() -> void:
	channel_selected.emit("TRITC")


func _on_cy_5_pressed() -> void:
	channel_selected.emit("Cy5")


func _on_combo_pressed() -> void:
	channel_selected.emit("Combo")
