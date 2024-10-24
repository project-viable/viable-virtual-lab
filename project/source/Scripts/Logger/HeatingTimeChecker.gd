extends MistakeChecker
class_name HeatingTimeChecker

@export var CorrectTimeToMicrowave: float = 60
@export var TooLongMessage: String
@export var TooShortMessage: String

func CheckAction(params: Dictionary):
	#Check if this action is even applicable to this checker:
	if params['actionType'] == 'heat' and params.get('heatTime'):
		#Now that we know we can check it, see if the user made a mistake:
		if params['heatTime'] < CorrectTimeToMicrowave:
			LabLog.Warn(TooShortMessage)
		elif params['heatTime'] > CorrectTimeToMicrowave:
			LabLog.Warn(TooLongMessage)
