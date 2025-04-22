extends MistakeChecker
class_name PipetteDispenseChecker

@export var correct_dna_volume: float = 0.005
@export var too_low_message: String
@export var too_high_message: String

func check_action(params: Dictionary) -> void:
	if params['action_type'] == 'transferSubstance' and params.get('substances'):
		print(params['action_type'])
		#for substance: Substance in params['substances']:
			#if substance.name != 'DNASubstance':
				#continue
			#if substance.has_method('get_properties'):
				#var volume: float = substance.get_properties()['volume']
				#if !is_equal_approx(volume, correct_dna_volume):
					#if volume < correct_dna_volume:
						#LabLog.warn(too_low_message)
					#elif volume > correct_dna_volume:
						#LabLog.warn(too_high_message)
