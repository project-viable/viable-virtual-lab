extends LabObject

var temperature: int = 32 #temperature of fridge in degrees celsius
var temperature_array: Array[int] = []
var fridge: LabObject = null # Stores the cell samples 

func get_temperature() -> float:
	var temp: float =0
	var array_len := len(temperature_array)
	match array_len:
		0:
			return temperature #If no inputs/cancel pressed, return the exisitng fride temperature to show no change in temperature
		1:
			return temperature_array[0] # user has entered a temperature
		_:
			return temperature

func display_temperature() -> void: #Made to display the fridge temperature in the TemperatureLabel
	var array_len := len(temperature_array)
	match array_len:
		0:
			$Menu/PanelContainer/VBoxContainer/TemperatureLabel.text = "32 \u00B0C" #default temperature is 32 degrees C
		1:
			$Menu/PanelContainer/VBoxContainer/TimeLabel.text = "%s \u00B0C" % str(temperature_array[0])
func _on_Button1_pressed() -> void:
	temperature_array.append(1)
	display_temperature()#Display new temperature


func _on_Button2_pressed() -> void:
	temperature_array.append(2)
	display_temperature()#Display new temperature


func _on_Button3_pressed() -> void:
	temperature_array.append(3)
	display_temperature()#Display new temperature


func _on_Button4_pressed() -> void:
	temperature_array.append(4)
	display_temperature()#Display new temperature


func _on_Button5_pressed() -> void:
	temperature_array.append(5)
	display_temperature()#Display new temperature


func _on_Button6_pressed() -> void:
	temperature_array.append(6)
	display_temperature()#Display new temperature


func _on_Button7_pressed() -> void:
	temperature_array.append(7)
	display_temperature()#Display new temperature


func _on_Button8_pressed() -> void:
	temperature_array.append(8)
	display_temperature()#Display new temperature


func _on_Button9_pressed() -> void:
	temperature_array.append(9)
	display_temperature()#Display new temperature


func _on_ClearButton_pressed() -> void: #Clear array to cancel input/return null when getTemperature is called
	temperature_array.clear()


func _on_Button0_pressed() -> void:
	temperature_array.append(0)
	display_temperature()#Display new temperature


func _on_DeleteButton_pressed() -> void:
	temperature_array.pop_back() #Remove the last input from the array
	display_temperature()#Display new temperature


func _on_EnterButton_pressed() -> void:
	temperature = get_temperature()
