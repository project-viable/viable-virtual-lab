extends Control

func _on_power_slider_value_changed(value: float) -> void:
	$Panel/HBoxContainer2/LEDPowerVal.text = str(value) + "%"


func _on_exposure_slider_value_changed(value: float) -> void:
	$Panel/HBoxContainer3/ExposureTimeVal.text = str(value) + " msec"
