extends MistakeChecker
class_name HeatingTimeChecker

@export var CorrectTimeToMicrowave: float = 60
@export var TooLongMessage: String
@export var TooShortMessage: String

func CheckAction(params: Dictionary) -> void:
	#Check if this action is even applicable to this checker:
	if params['action_type'] == 'heat' and params.get('heat_time'):
		#Now that we know we can check it, see if the user made a mistake:
		if params['heat_time'] < CorrectTimeToMicrowave:
			LabLog.Warn(TooShortMessage)
		elif params['heat_time'] > CorrectTimeToMicrowave:
			LabLog.Warn(TooLongMessage)
