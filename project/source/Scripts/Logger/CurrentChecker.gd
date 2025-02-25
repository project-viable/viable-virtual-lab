extends MistakeChecker
class_name CurrentChecker

@export var CorrectVoltage: float = 120
@export var TooHighMessage: String
@export var TooLowMessage: String
@export var ReversedMessage: String

func check_action(params: Dictionary) -> void:
	if params['action_type'] == 'runCurrent' and params.get('voltage'):
		if params['voltage'] < 0:
			LabLog.warn(ReversedMessage)
		if abs(params['voltage']) < CorrectVoltage:
			LabLog.warn(TooLowMessage)
		elif abs(params['voltage']) > CorrectVoltage:
			LabLog.warn(TooHighMessage)
