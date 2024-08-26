extends LabObject

export(int) var wellNumber = 0
var broken = false

func AddContents(new_contents):
	#TODO: This could do the wrong thing if an object other than the pipette being handled by the Proxy tries to add liquid.
	print("-gel well add contents")
	
	for content in new_contents:
		if not content.is_in_group('DNA'):
			#uhhh
			#not something you should do, so I guess we'll give it to the parent object instead?
			GetSubsceneManagerParent().AddContents([content])
			return
		
		#If the well is broken, you can't add stuff to it.
		if broken:
			AddLow(content)
			
		# We need to see if it's more than 0.05 mL (50µL)
		# If greater, AddHigh with no extra Warning
		var volume = content.get_volume()
		var max_volume = 50
		
		###See what the thing is colliding with:
		#check low
		for other in $LowArea.get_overlapping_bodies():
			if other is Pipette:
				if volume >= max_volume:
					AddHigh(content, false)
					LabLog.Warn("Added more than 50 µL of DNA substance")
				else:
					AddLow(content)
				return
		#check mid
		for other in $MidArea.get_overlapping_bodies():
			if other is Pipette:
				if volume >= max_volume:
					AddHigh(content, false)
					LabLog.Warn("Added more than 50 µL of DNA substance")
				else:
					AddMid(content)
				return
		#check high
		for other in $HighArea.get_overlapping_bodies():
			if other is Pipette:
				AddHigh(content)
				return

func AddHigh(new_contents, send_warn=true):
	if send_warn:
		LabLog.Warn("Added too High")
	$HighArea/AddedHighVisual.show()
	#TODO: the contents go nowhere. Is this correct?

func AddMid(new_contents):
	LabLog.Log("Added a substance to the gel well")
	GetSubsceneManagerParent().add_dna(new_contents, wellNumber)
	$MidArea/AddedMidVisual.show()

func AddLow(new_contents):
	broken = true
	LabLog.Warn("Added too Low")
	$LowArea/AddedLowVisual.show()
	#TODO: the contents go nowhere. Is this correct?
