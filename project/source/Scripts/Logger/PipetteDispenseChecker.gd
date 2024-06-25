extends MistakeChecker
class_name PipetteDispenseChecker

export(float) var CorrectDNAVolume = 0.005
export(String) var TooLowMessage
export(String) var TooHighMessage

func CheckAction(params: Dictionary):
	if params['actionType'] == 'transferSubstance' and params.get('substances'):
		print(params['actionType'])
		for substance in params['substances']:
			if substance.name != 'DNASubstance':
				continue
			if substance.has_method('get_properties'):
				var volume: float = substance.get_properties()['volume']
				if !is_equal_approx(volume, CorrectDNAVolume):
					if volume < CorrectDNAVolume:
						LabLog.Warn(TooLowMessage)
					elif volume > CorrectDNAVolume:
						LabLog.Warn(TooHighMessage)
