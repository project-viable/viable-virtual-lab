extends MistakeChecker
class_name MixtureChecker

var Mixtures: Dictionary

func CheckAction(params: Dictionary):
	if params['actionType'] == 'mixSubstance' and params.get('substances'):
		var hasError: bool = false
		var substances = params.get('substances')
		if Mixtures == {}:
			return
		var combinedSubstance = params['objectsInvolved'][0]
		# We want to strip numbers and remove @ symbols from the name
		# because instantiating a substance more than once will add these characters
		var combinedSubstanceName = combinedSubstance.name.rstrip('0123456789').replace('@', '')
		if Mixtures.get(combinedSubstanceName):
			var targetSubstance = Mixtures.get(combinedSubstanceName)['substances']
			# Compare each substance
			for substanceName in substances:
				var substance = substances[substanceName]
				if not targetSubstance.get(substanceName):
					LabLog.Warn('Substance ' + substanceName + ' does not belong in ' + combinedSubstance)
					continue
				var volume = substance['volume']
				var targetVolume = targetSubstance.get(substanceName)['volume']
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
