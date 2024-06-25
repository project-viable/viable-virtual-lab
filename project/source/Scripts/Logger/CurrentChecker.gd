extends MistakeChecker
class_name CurrentChecker

export(float) var CorrectVoltage = 120
export(String) var TooHighMessage
export(String) var TooLowMessage
export(String) var ReversedMessage

func CheckAction(params: Dictionary):
	if params['actionType'] == 'runCurrent' and params.get('voltage'):
		if params['voltage'] < 0:
			LabLog.Warn(ReversedMessage)
		if abs(params['voltage']) < CorrectVoltage:
			LabLog.Warn(TooLowMessage)
		elif abs(params['voltage']) > CorrectVoltage:
			LabLog.Warn(TooHighMessage)
