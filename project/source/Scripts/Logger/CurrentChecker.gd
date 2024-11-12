extends MistakeChecker
class_name CurrentChecker

@export var CorrectVoltage: float = 120
@export var TooHighMessage: String
@export var TooLowMessage: String
@export var ReversedMessage: String

func CheckAction(params: Dictionary) -> void:
	if params['actionType'] == 'runCurrent' and params.get('voltage'):
		if params['voltage'] < 0:
			LabLog.Warn(ReversedMessage)
		if abs(params['voltage']) < CorrectVoltage:
			LabLog.Warn(TooLowMessage)
		elif abs(params['voltage']) > CorrectVoltage:
			LabLog.Warn(TooHighMessage)
