extends MistakeChecker

func CurrentChecker(params: Array) -> void:
	var voltage: int
	voltage = params[0]
	if voltage < 0:
		LabLog.Warn("You reversed the currents. Running the gel like this will run the substance off the gel.")
		if voltage < -120:
			LabLog.Warn("The voltage was set too high. This made the gel run faster. Set it to 120V for this lab.")
		if voltage > -120:
			LabLog.Warn("The voltage was set too low. This made the gel run slower. Set it to 120V for this lab.")
		return

	if voltage > 120:
		LabLog.Warn("The voltage was set too high. This made the gel run faster. Set it to 120V for this lab.")
	if voltage < 120:
		LabLog.Warn("The voltage was set too low. This made the gel run slower. Set it to 120V for this lab.")
	return

func HeatingChecker(params: Array) -> void:
	var totalHeatTime: int
	totalHeatTime = params[0]
	
	if(totalHeatTime < 60):
		LabLog.Warn("Gel Mixture was heated up for less than one minute, substance may not combine properly")
	if(totalHeatTime > 60):
		LabLog.Warn("Gel Mixture was heated up for more than one minute, substance may not combine properly")
