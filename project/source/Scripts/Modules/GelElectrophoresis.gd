extends MistakeChecker

func CurrentReveresedChecker(params: Array) -> void:
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
