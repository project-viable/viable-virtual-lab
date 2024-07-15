extends LabObject

var broken = false

func AddContents(new_contents):
	#TODO: This could do the wrong thing if an object other than the pipette being handled by the Proxy tries to add liquid.
	print("-gel well add contents")
	
	#If the well is broken, you can't add stuff to it.
	if broken:
		AddLow(new_contents)
	
	###See what the thing is colliding with:
	#check low
	for other in $LowArea.get_overlapping_bodies():
		if other is Pipette:
			AddLow(new_contents)
			return
	#check mid
	for other in $MidArea.get_overlapping_bodies():
		if other is Pipette:
			AddMid(new_contents)
			return
	#check high
	for other in $HighArea.get_overlapping_bodies():
		if other is Pipette:
			AddHigh(new_contents)
			return

func AddHigh(new_contents):
	LabLog.Warn("Added too High")
	$HighArea/AddedHighVisual.show()
	#TODO: the contents go nowhere. Is this correct?

func AddMid(new_contents):
	LabLog.Log("Added a substance to the gel well")
	GetSubsceneManagerParent().AddContents(new_contents)
	$MidArea/AddedMidVisual.show()

func AddLow(new_contents):
	broken = true
	LabLog.Warn("Added too Low")
	$LowArea/AddedLowVisual.show()
	#TODO: the contents go nowhere. Is this correct?
