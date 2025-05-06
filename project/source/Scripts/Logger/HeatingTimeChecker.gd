extends MistakeChecker
class_name HeatingTimeChecker

@export var correct_time_to_microwave: float = 60
@export var too_long_message: String
@export var too_short_message: String

func check_action(params: Dictionary) -> void:
	#Check if this action is even applicable to this checker:
	if params['action_type'] == 'heat' and params.get('heat_time'):
		#Now that we know we can check it, see if the user made a mistake:
		if params['heat_time'] < correct_time_to_microwave:
			LabLog.warn(too_short_message)
		elif params['heat_time'] > correct_time_to_microwave:
			LabLog.warn(too_long_message)
