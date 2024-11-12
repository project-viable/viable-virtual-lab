extends MistakeChecker
class_name MixtureChecker

var Mixtures: Dictionary

func CheckAction(params: Dictionary) -> void:
	if params['actionType'] == 'mixSubstance' and params.get('substances'):
		var hasError: bool = false
		var substances: Dictionary = params.get('substances')
		if Mixtures == {}:
			return
		var combinedSubstance: Node2D = params['objectsInvolved'][0]
		# We want to strip numbers and remove @ symbols from the name
		# because instantiating a substance more than once will add these characters
		var combinedSubstanceName: String = combinedSubstance.name.rstrip('0123456789').replace('@', '')
		if Mixtures.get(combinedSubstanceName):
			var targetSubstance: Dictionary = Mixtures.get(combinedSubstanceName)['substances']
			# Compare each substance
			for substanceName: String in substances:
				var substance: Dictionary = substances[substanceName]
				if not targetSubstance.get(substanceName):
					LabLog.Warn('Substance ' + substanceName + ' does not belong in ' + combinedSubstanceName)
					continue
				var volume: float = substance['volume']
				var targetVolume:float = targetSubstance.get(substanceName)['volume']
				print('volume: ', volume, ', target volume: ', targetVolume)
				if not is_equal_approx(volume, targetVolume):
					hasError = true
					if volume < targetVolume:
						LabLog.Warn('Used too little ' + substanceName + ' for making ' + combinedSubstanceName)
					elif volume > targetVolume:
						LabLog.Warn('Used too much ' + substanceName + ' for making ' + combinedSubstanceName)
			if not hasError:
				LabLog.Log('Created ' + combinedSubstanceName)
				return
