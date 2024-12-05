extends LabObject

var heatTime: int = 0 #heatTime is in seconds
var timeArray: Array[int] = []
var heatable: LabObject = null # Stores the heatable interacting with the microwave in order to let the function wait
					#For the menu input to end before heating

func _ready() -> void:
	$Menu.hide()

func getTime() -> float:
	var temp: float =0
	var arrayLen := len(timeArray)
	match arrayLen:
		0:
			return 0 #If no inputs/cancel pressed, return null for no heating
		1:
			return timeArray[0] # heat time is <10 seconds
		2:
			return (timeArray[0] * 10) + timeArray[1] #Heat time has >=10 seconds, but nothing in minutes spot
		_:
			for x in range(arrayLen - 2):# Iterate through the minutes, last 2 values are seconds, so don't count yet
					temp += timeArray[x] * 60 * pow(10, arrayLen-3-x) #Multiply minute number by 60 to get seconds
																#and by a power of 10 dependent on place in the number
			temp += (timeArray[arrayLen - 2] * 10) + timeArray[arrayLen - 1] #Add in the seconds
			return temp

func displayTime() -> void: #Made to display the microwave time in the TimeLabel
	var time := ""
	var arrayLen := len(timeArray)
	match arrayLen:
		0:
			$Menu/PanelContainer/VBoxContainer/TimeLabel.text = "0:00" #default time is 0
		1:
			$Menu/PanelContainer/VBoxContainer/TimeLabel.text = "0:0%s" % str(timeArray[0])
		2:
			$Menu/PanelContainer/VBoxContainer/TimeLabel.text = "0:%s" % (str(timeArray[0]) + str(timeArray[1]))
		_:
			for x in range(arrayLen - 2):# Iterate through the minutes, last 2 values are seconds, so wait for :
					time += str(timeArray[x])
			time += ":"
			time = time + str(timeArray[arrayLen - 2]) + str(timeArray[arrayLen - 1]) #Add in the seconds
			$Menu/PanelContainer/VBoxContainer/TimeLabel.text = "%s" % time

func TryInteract(others: Array[LabObject]) -> bool:
	#When the microwave is clicked and touching another object, it'll call this function
	for other in others:
		if other.is_in_group("Heatable"): #Only heat heatables
			timeArray.clear() #Reset time array to allow subsequent heatings
			heatable = other #Store the object to use later
			$Menu.visible = !$Menu.visible #show popup menu
			displayTime()#Display default time

			return true

	return false


# TODO (update): This can be just one function `_on_number_button_pressed(digit: int)`, which can
# have the corresponding digit bound to the argument when the signal is connected.
func _on_1Button_pressed() -> void:
	timeArray.append(1)
	displayTime()#Display new time


func _on_2Button_pressed() -> void:
	timeArray.append(2)
	displayTime()#Display new time


func _on_3Button_pressed() -> void:
	timeArray.append(3)
	displayTime()#Display new time


func _on_4Button_pressed() -> void:
	timeArray.append(4)
	displayTime()#Display new time


func _on_5Button_pressed() -> void:
	timeArray.append(5)
	displayTime()#Display new time


func _on_6Button_pressed() -> void:
	timeArray.append(6)
	displayTime()#Display new time


func _on_7Button_pressed() -> void:
	timeArray.append(7)
	displayTime()#Display new time


func _on_8Button_pressed() -> void:
	timeArray.append(8)
	displayTime()#Display new time


func _on_9Button_pressed() -> void:
	timeArray.append(9)
	displayTime()#Display new time


func _on_ClearButton_pressed() -> void: #Clear array to cancel input/return null when getTime is called, 
								#then hide menu to continue module
	timeArray.clear()
	$Menu.hide() 


func _on_0Button_pressed() -> void:
	timeArray.append(0)
	displayTime()#Display new time


func _on_BackButton_pressed() -> void:
	timeArray.pop_back() #Remove the last input from the array
	displayTime()#Display new time


func _on_StartButton_pressed() -> void:
	$Menu.hide() #Just hide the menu so the tryInteract function continues with current array contents
	heatTime = getTime()
	if(heatTime != 0):#If it should heat
		print("Heattime check " + str(heatTime))
		heatable.heat(heatTime)
		LabLog.Log("Microwaved for " + str(heatTime) + " seconds.", false, true)
		ReportAction([self, heatable], "heat", {'heatTime': heatTime})
