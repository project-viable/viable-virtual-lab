extends MistakeChecker
class_name MixtureChecker

var Mixtures: Dictionary

func CheckAction(params: Dictionary):
	if params['actionType'] == 'mixSubstance' and params.get('substances'):
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
				print(volume, ': ', targetVolume)
				if volume < targetVolume:
					LabLog.Warn('Used too little ' + substanceName)
				elif volume > targetVolume:
					LabLog.Warn('Used too much ' + substanceName)
