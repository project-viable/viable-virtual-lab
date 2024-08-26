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
		
		###See what the thing is colliding with:
		#check low
		for other in $LowArea.get_overlapping_bodies():
			if other is Pipette:
				AddLow(content)
				return
		#check mid
		for other in $MidArea.get_overlapping_bodies():
			if other is Pipette:
				AddMid(content)
				return
		#check high
		for other in $HighArea.get_overlapping_bodies():
			if other is Pipette:
				AddHigh(content)
				return

func CheckContents(group):
	#we're a fake container actually, so no.
	return false

func AddHigh(new_contents):
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
