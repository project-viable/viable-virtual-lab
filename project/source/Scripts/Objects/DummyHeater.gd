extends LabObject

var heatTime = null #heatTime is in seconds
var timeArray = []
var heatable = null # Stores the heatable interacting with the microwave in order to let the function wait
					#For the menu input to end before heating

func _ready():
	$Menu.hide()

func getTime():
	var temp=0
	var arrayLen = len(timeArray)
	match arrayLen:
		0:
			return null #If no inputs/cancel pressed, return null for no heating
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
	return null
	
func displayTime(): #Made to display the microwave time in the TimeLabel
	var time = ""
	var arrayLen = len(timeArray)
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

func TryInteract(others):
	#When the microwave is clicked and touching another object, it'll call this function
	for other in others:
		if other.is_in_group("Heatable"): #Only heat heatables
			timeArray.clear() #Reset time array to allow subsequent heatings
			heatable = other #Store the object to use later
			$Menu.visible = !$Menu.visible #show popup menu
			displayTime()#Display default time


func _on_1Button_pressed():
	timeArray.append(1)
	displayTime()#Display new time


func _on_2Button_pressed():
	timeArray.append(2)
	displayTime()#Display new time


func _on_3Button_pressed():
	timeArray.append(3)
	displayTime()#Display new time


func _on_4Button_pressed():
	timeArray.append(4)
	displayTime()#Display new time


func _on_5Button_pressed():
	timeArray.append(5)
	displayTime()#Display new time


func _on_6Button_pressed():
	timeArray.append(6)
	displayTime()#Display new time


func _on_7Button_pressed():
	timeArray.append(7)
	displayTime()#Display new time


func _on_8Button_pressed():
	timeArray.append(8)
	displayTime()#Display new time


func _on_9Button_pressed():
	timeArray.append(9)
	displayTime()#Display new time


func _on_ClearButton_pressed(): #Clear array to cancel input/return null when getTime is called, 
								#then hide menu to continue module
	timeArray.clear()
	$Menu.hide() 


func _on_0Button_pressed():
	timeArray.append(0)
	displayTime()#Display new time


func _on_BackButton_pressed():
	timeArray.pop_back() #Remove the last input from the array
	displayTime()#Display new time


func _on_StartButton_pressed():
	$Menu.hide() #Just hide the menu so the tryInteract function continues with current array contents
	heatTime = getTime()
	if(heatTime != null):#If it should heat
		print("Heattime check " + str(heatTime))
		heatable.heat(heatTime)
		ReportAction([self, heatable], "heat", {'heatedContents': heatable.contents})
