extends MistakeChecker

func CurrentReveresedChecker(params: Array) -> void:
	var voltage: int
	var time: int
	if len(params) != 2:
		return
	voltage = params[0]
	time = params[1]
	if voltage < 0:
		LabLog.Warn("You reversed the currents. Running the gel like this will run the substance off the gel.")
	return
