extends LabObject

var heat_time: int = 0 #heat_time is in seconds
var time_array: Array[int] = []
var heatable: LabObject = null # Stores the heatable interacting with the microwave in order to let the function wait
					#For the menu input to end before heating

func lab_object_ready() -> void:
	$Menu.hide()

func get_time() -> float:
	var temp: float =0
	var array_len := len(time_array)
	match array_len:
		0:
			return 0 #If no inputs/cancel pressed, return null for no heating
		1:
			return time_array[0] # heat time is <10 seconds
		2:
			return (time_array[0] * 10) + time_array[1] #Heat time has >=10 seconds, but nothing in minutes spot
		_:
			for x in range(array_len - 2):# Iterate through the minutes, last 2 values are seconds, so don't count yet
					temp += time_array[x] * 60 * pow(10, array_len-3-x) #Multiply minute number by 60 to get seconds
																#and by a power of 10 dependent on place in the number
			temp += (time_array[array_len - 2] * 10) + time_array[array_len - 1] #Add in the seconds
			return temp

func display_time() -> void: #Made to display the microwave time in the TimeLabel
	var time := ""
	var array_len := len(time_array)
	match array_len:
		0:
			$Menu/PanelContainer/VBoxContainer/TimeLabel.text = "0:00" #default time is 0
		1:
			$Menu/PanelContainer/VBoxContainer/TimeLabel.text = "0:0%s" % str(time_array[0])
		2:
			$Menu/PanelContainer/VBoxContainer/TimeLabel.text = "0:%s" % (str(time_array[0]) + str(time_array[1]))
		_:
			for x in range(array_len - 2):# Iterate through the minutes, last 2 values are seconds, so wait for :
					time += str(time_array[x])
			time += ":"
			time = time + str(time_array[array_len - 2]) + str(time_array[array_len - 1]) #Add in the seconds
			$Menu/PanelContainer/VBoxContainer/TimeLabel.text = "%s" % time

func try_interact(others: Array[LabObject]) -> bool:
	#When the microwave is clicked and touching another object, it'll call this function
	for other in others:
		if other.is_in_group("Heatable"): #Only heat heatables
			time_array.clear() #Reset time array to allow subsequent heatings
			heatable = other #Store the object to use later
			$Menu.visible = !$Menu.visible #show popup menu
			display_time()#Display default time

			return true

	return false


# TODO (update): This can be just one function `_on_number_button_pressed(digit: int)`, which can
# have the corresponding digit bound to the argument when the signal is connected.
func _on_1Button_pressed() -> void:
	time_array.append(1)
	display_time()#Display new time


func _on_2Button_pressed() -> void:
	time_array.append(2)
	display_time()#Display new time


func _on_3Button_pressed() -> void:
	time_array.append(3)
	display_time()#Display new time


func _on_4Button_pressed() -> void:
	time_array.append(4)
	display_time()#Display new time


func _on_5Button_pressed() -> void:
	time_array.append(5)
	display_time()#Display new time


func _on_6Button_pressed() -> void:
	time_array.append(6)
	display_time()#Display new time


func _on_7Button_pressed() -> void:
	time_array.append(7)
	display_time()#Display new time


func _on_8Button_pressed() -> void:
	time_array.append(8)
	display_time()#Display new time


func _on_9Button_pressed() -> void:
	time_array.append(9)
	display_time()#Display new time


func _on_ClearButton_pressed() -> void: #Clear array to cancel input/return null when getTime is called, 
								#then hide menu to continue module
	time_array.clear()
	$Menu.hide() 


func _on_0Button_pressed() -> void:
	time_array.append(0)
	display_time()#Display new time


func _on_BackButton_pressed() -> void:
	time_array.pop_back() #Remove the last input from the array
	display_time()#Display new time


func _on_StartButton_pressed() -> void:
	$Menu.hide() #Just hide the menu so the tryInteract function continues with current array contents
	heat_time = get_time()
	if(heat_time != 0):#If it should heat
		print("Heattime check " + str(heat_time))
		heatable.heat(heat_time)
		LabLog.log("Microwaved for " + str(heat_time) + " seconds.", false, true)
		report_action([self, heatable], "heat", {'heat_time': heat_time})
