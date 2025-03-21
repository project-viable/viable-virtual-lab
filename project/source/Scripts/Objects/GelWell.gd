extends LabObject

@export var well_number: int = 0
var broken: bool = false

func lab_object_ready() -> void:
	freeze = true

func add_contents(new_contents: Array[Substance]) -> void:
	#TODO: This could do the wrong thing if an object other than the pipette being handled by the Proxy tries to add liquid.
	print("-gel well add contents")
	
	for content in new_contents:
		if not content.is_in_group('DNA'):
			#uhhh
			#not something you should do, so I guess we'll give it to the parent object instead?
			get_subscene_manager_parent().add_contents([content])
			return
		
		#If the well is broken, you can't add stuff to it.
		if broken:
			add_low(content)
			
		# We need to see if it's more than 0.05 mL (50µL)
		# If greater, AddHigh with no extra Warning
		var volume := content.get_volume()
		var max_volume: float = 50
		
		###See what the thing is colliding with:
		#check low
		for other: Node2D in $LowArea.get_overlapping_bodies():
			if other is Pipette:
				if volume >= max_volume:
					add_high(content, false)
					LabLog.warn("Added more than 50 µL of DNA substance")
				else:
					add_low(content)
				return
		#check mid
		for other: Node2D in $MidArea.get_overlapping_bodies():
			if other is Pipette:
				if volume >= max_volume:
					add_high(content, false)
					LabLog.warn("Added more than 50 µL of DNA substance")
				else:
					add_mid(content)
				return
		#check high
		for other: Node2D in $HighArea.get_overlapping_bodies():
			if other is Pipette:
				add_high(content)
				return

# TODO (update): This should return `Array[bool]` to match the other functions.
func check_contents(group: StringName) -> Array[bool]:
	#we're a fake container actually, so no.
	return []

func add_high(new_contents: DNASubstance, send_warn := true) -> void:
	if send_warn:
		LabLog.warn("Added too High")

	$HighArea/AddedHighVisual.show()
	#TODO: the contents go nowhere. Is this correct?

func add_mid(new_contents: DNASubstance) -> void:
	LabLog.log("Added a substance to the gel well")
	get_subscene_manager_parent().add_dna(new_contents, well_number)
	$MidArea/AddedMidVisual.show()

func add_low(new_contents: DNASubstance) -> void:
	broken = true
	LabLog.warn("Added too Low")
	$LowArea/AddedLowVisual.show()
	#TODO: the contents go nowhere. Is this correct?
