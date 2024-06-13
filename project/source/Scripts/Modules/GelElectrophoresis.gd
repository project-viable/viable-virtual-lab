extends MistakeChecker

func CurrentReveresedChecker(params: Array) -> void:
	var voltage: int
	voltage = params[0]
	if voltage < 0:
		LabLog.Warn("You reversed the currents. Running the gel like this will run the substance off the gel.")
	return
