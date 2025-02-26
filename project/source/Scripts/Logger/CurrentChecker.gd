extends MistakeChecker
class_name CurrentChecker

@export var CorrectVoltage: float = 120
@export var too_high_message: String
@export var too_low_message: String
@export var ReversedMessage: String

func check_action(params: Dictionary) -> void:
	if params['action_type'] == 'runCurrent' and params.get('voltage'):
		if params['voltage'] < 0:
			LabLog.warn(ReversedMessage)
		if abs(params['voltage']) < CorrectVoltage:
			LabLog.warn(too_low_message)
		elif abs(params['voltage']) > CorrectVoltage:
			LabLog.warn(too_high_message)
