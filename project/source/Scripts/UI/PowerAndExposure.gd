extends Control
signal power_change(new_power: float)
signal exposure_change(new_exposure: float)
signal combo_change(selected_channel: String, attribute: String, value: float)

func _on_power_slider_value_changed(value: float) -> void:
	$GeneralPanel/HBoxContainer2/LEDPowerVal.text = str(value) + "%"
	power_change.emit(value)


func _on_exposure_slider_value_changed(value: float) -> void:
	$GeneralPanel/HBoxContainer3/ExposureTimeVal.text = str(value) + " msec"
	exposure_change.emit(value)


func _on_Dapi_power_slider_value_changed(value: float) -> void:
	$ComboPanel/DapiPower/LEDPowerVal.text = str(value) + "%"
	combo_change.emit("Dapi", "Power", value)


func _on_Dapi_exposure_slider_value_changed(value: float) -> void:
	$ComboPanel/DapiExposure/ExposureTimeVal.text = str(value) + " msec"
	combo_change.emit("Dapi", "Exposure", value)


func _on_FITC_power_slider_value_changed(value: float) -> void:
	$ComboPanel/FITCPower/LEDPowerVal.text = str(value) + "%"
	combo_change.emit("FITC", "Power", value)


func _on_FITC_exposure_slider_value_changed(value: float) -> void:
	$ComboPanel/FITCExposure/ExposureTimeVal.text = str(value) + " msec"
	combo_change.emit("FITC", "Exposure", value)


func _on_RITC_power_slider_value_changed(value: float) -> void:
	$ComboPanel/TRITCPower/LEDPowerVal.text = str(value) + "%"
	combo_change.emit("TRITC", "Power", value)


func _on_RITC_exposure_slider_value_changed(value: float) -> void:
	$ComboPanel/TRITCExposure/ExposureTimeVal.text = str(value) + " msec"
	combo_change.emit("TRITC", "Exposure", value)


func _on_Cy5_power_slider_value_changed(value: float) -> void:
	$ComboPanel/Cy5Power/LEDPowerVal.text = str(value) + "%"
	combo_change.emit("Cy5", "Power", value)


func _on_Cy5_exposure_slider_value_changed(value: float) -> void:
	$ComboPanel/Cy5Exposure/ExposureTimeVal.text = str(value) + " msec"
	combo_change.emit("Cy5", "Exposure", value)
