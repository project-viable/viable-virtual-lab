extends MistakeChecker

var idealVoltage = 120
var idealHeatTime = 60
var idealAgarVolume = 1
var idealBinderVolume = 50
var idealDNAVolume = 0.005

func CurrentChecker(params: Array) -> void:
	var voltage: int
	voltage = params[0]
	if voltage < 0:
		LabLog.Warn("You reversed the currents. Running the gel like this will run the substance off the gel.")
		if voltage < -idealVoltage:
			LabLog.Warn("The voltage was set too high. This made the gel run faster. Set it to 120V for this lab.")
		if voltage > -idealVoltage:
			LabLog.Warn("The voltage was set too low. This made the gel run slower. Set it to 120V for this lab.")
		return

	if voltage > idealVoltage:
		LabLog.Warn("The voltage was set too high. This made the gel run faster. Set it to 120V for this lab.")
	if voltage < idealVoltage:
		LabLog.Warn("The voltage was set too low. This made the gel run slower. Set it to 120V for this lab.")
	return

func HeatingChecker(params: Array) -> void:
	var totalHeatTime: int
	totalHeatTime = params[0]
	
	if(totalHeatTime < idealHeatTime):
		LabLog.Warn("Gel Mixture was heated up for less than one minute, substance may not combine properly")
	if(totalHeatTime > idealHeatTime):
		LabLog.Warn("Gel Mixture was heated up for more than one minute, substance may not combine properly")

func MixChecker(params: Array) -> void:
	var agarVolume: float
	var binderVolume: float
	agarVolume = params[0]
	binderVolume = params[1]
	if (agarVolume > idealAgarVolume):
		LabLog.Warn("Used too much agarose")
	elif (agarVolume < idealAgarVolume):
		LabLog.Warn("Used too little agarose")
	
	if (binderVolume > idealBinderVolume):
		LabLog.Warn("Used too much TAE Buffer Solution")
	elif (binderVolume < idealBinderVolume):
		LabLog.Warn("Used too little TAE Buffer Solution")
		
func PipetteDispenseChecker(params: Array) -> void:
	var drawVolume: float
	var contents: Array
	contents = params[0]
	for content in contents:
		drawVolume = content.get_properties().volume
		if content.name == "DNASubstance":
			# This is necessary, as otherwise checking if two equal floats are different will yield that they are different
			if !is_equal_approx(drawVolume, idealDNAVolume):
				if drawVolume < idealDNAVolume:
					LabLog.Warn("Pipette dispensing less than 5uL of DNA sample")
				elif drawVolume > idealDNAVolume:
					LabLog.Warn("Pipette dispensing more than 5uL of DNA sample")
