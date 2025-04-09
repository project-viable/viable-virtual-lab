extends MistakeChecker
class_name CurrentChecker

@export var correct_voltage: float = 120
@export var too_high_message: String
@export var too_low_message: String
@export var reversed_message: String

func check_action(params: Dictionary) -> void:
	if params['action_type'] == 'runCurrent' and params.get('voltage'):
		if params['voltage'] < 0:
			LabLog.warn(reversed_message)
		if abs(params['voltage']) < correct_voltage:
			LabLog.warn(too_low_message)
		elif abs(params['voltage']) > correct_voltage:
			LabLog.warn(too_high_message)
