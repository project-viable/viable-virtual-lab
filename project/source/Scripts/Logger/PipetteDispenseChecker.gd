extends MistakeChecker
class_name PipetteDispenseChecker

@export var CorrectDNAVolume: float = 0.005
@export var TooLowMessage: String
@export var TooHighMessage: String

func CheckAction(params: Dictionary) -> void:
	if params['action_type'] == 'transferSubstance' and params.get('substances'):
		print(params['action_type'])
		for substance: Substance in params['substances']:
			if substance.name != 'DNASubstance':
				continue
			if substance.has_method('get_properties'):
				var volume: float = substance.get_properties()['volume']
				if !is_equal_approx(volume, CorrectDNAVolume):
					if volume < CorrectDNAVolume:
						LabLog.Warn(TooLowMessage)
					elif volume > CorrectDNAVolume:
						LabLog.Warn(TooHighMessage)
