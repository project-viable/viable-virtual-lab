extends MistakeChecker

func RunCurrentMistakeChecker(params: Array) -> void:
	var voltage: int
	var time: int
	if len(params) != 2:
		return
	voltage = params[0]
	time = params[1]
	LabLog.Log(str(voltage) + ", " + str(time))
