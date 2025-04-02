extends StaticBody2D

var temperature: int = 32 #temperature of fridge in degrees celsius
var temperature_array: Array[int] = []
var fridge: LabObject = null # Stores the cell samples 
var click : bool = false

func _ready() -> void:
	$Control.hide()
	#print("default temperature = " ,temperature)
	
#When a user clicks on the fridge,the panel for inside the fridge opens
func _on_fridge_click_event(viewport: Viewport, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		click = true
		$Control.visible = !$Control.visible #show popup menu
	else:
		click = false

func get_temperature() -> int:
	#print(temperature_array)
	var temp:= ""
	var array_len := len(temperature_array)
	if array_len< 1:
		#print("temperature = " ,temperature)
		return temperature #If no inputs/cancel pressed, return the exisitng fride temperature to show no change in temperature
	else:
		for i in range(0, array_len):
			temp+= str(temperature_array[i])
		
		print("temperature = " ,int(temp))
		return int(temp)

func display_temperature() -> void: #Made to display the fridge temperature in the TemperatureLabel
	var temp:= ""
	var array_len := len(temperature_array)
	if array_len < 1:
		$Control/PanelContainer/VBoxContainer/FridgeInside/TemperatureLabel.text = "Set \u00B0C" #default temperature is 32 degrees C
	else:
		for i in range(0, array_len):
			temp+= str(temperature_array[i])
		$Control/PanelContainer/VBoxContainer/FridgeInside/TemperatureLabel.text = "%s \u00B0C" % temp
			
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
	display_temperature()

func _on_Button0_pressed() -> void:
	temperature_array.append(0)
	display_temperature()#Display new temperature

func _on_DeleteButton_pressed() -> void:
	temperature_array.pop_back() #Remove the last input from the array
	display_temperature()#Display new temperature

func _on_EnterButton_pressed() -> void:
	temperature = get_temperature()
	display_temperature()
	temperature_array.clear()
	
func _on_ExitButton_pressed() -> void:
	$Control.hide() #Closing the fridge
