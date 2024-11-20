extends MistakeChecker
class_name MixtureChecker

var Mixtures: Dictionary

func CheckAction(params: Dictionary) -> void:
	if params['actionType'] == 'mixSubstance' and params.get('substances'):
		var has_error: bool = false
		var substances: Dictionary = params.get('substances')
		if Mixtures == {}:
			return
		var combined_substance: Node2D = params['objectsInvolved'][0]
		# We want to strip numbers and remove @ symbols from the name
		# because instantiating a substance more than once will add these characters
		var combined_substance_name: String = combined_substance.name.rstrip('0123456789').replace('@', '')
		if Mixtures.get(combined_substance_name):
			var target_substance: Dictionary = Mixtures.get(combined_substance_name)['substances']
			# Compare each substance
			for substance_name: String in substances:
				var substance: Dictionary = substances[substance_name]
				if not target_substance.get(substance_name):
					LabLog.Warn('Substance ' + substance_name + ' does not belong in ' + combined_substance_name)
					continue
				var volume: float = substance['volume']
				var target_volume:float = target_substance.get(substance_name)['volume']
				print('volume: ', volume, ', target volume: ', target_volume)
				if not is_equal_approx(volume, target_volume):
					has_error = true
					if volume < target_volume:
						LabLog.Warn('Used too little ' + substance_name + ' for making ' + combined_substance_name)
					elif volume > target_volume:
						LabLog.Warn('Used too much ' + substance_name + ' for making ' + combined_substance_name)
			if not has_error:
				LabLog.Log('Created ' + combined_substance_name)
				return
