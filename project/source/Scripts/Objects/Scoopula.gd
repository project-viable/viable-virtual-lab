extends LabContainer

var dispense_mode = 0
var split_substance = [] 

var targetObj = null

func TryInteract(others):
	for other in others:#If interacting with container then we want to dispense or pick up
		if other.is_in_group("Container") or other.is_in_group("Source Container"):
			var granularSubstance = other.CheckContents("Granular Substance")
			if typeof(granularSubstance) == TYPE_ARRAY:
				if len(granularSubstance) > 0:
					granularSubstance = granularSubstance[0]
			if len(contents) == 0 and granularSubstance:
				# get density to determine volume taken
				var density = other.TakeContents()[0].get_properties()['density']
				
				contents.append_array(other.TakeContents(1 / density)) # Take 1g of material
				if(other.is_in_group("Scale")):
					other.UpdateWeight()
				print("Added contents")
				if contents != []:
					LabLog.Log("Added " + contents[0].name + " to scoopula.")
				update_display()
				return true
			else:
				if(!contents.empty()):
					var contentName = contents[0].name
					
					#Show menu
					$ScoopulaMenu.popup()
					$ScoopulaMenu.rect_global_position = global_position
					$ScoopulaMenu/PanelContainer/sliderDispenseQty.max_value = contents[0].volume
					
					targetObj = other
						#split_substance.append(SplitContents())
						#other.AddContents(split_substance)
				update_display()
				return true
	return false

func SplitContents():
	if(contents.empty()):
		print("empty")
		return null
	else:
		print("array check")
		var split = contents[0].duplicate()
		if(contents[0].get_volume() <= .1/split.get_density()):
			split.set_volume(contents[0].get_volume())
			contents.clear()
			return split
		else:
			print("Prevolume" + str(contents[0].volume))
			split.set_volume(.1/split.get_density()) 
			print("Split volume: " + str(split.volume))
			contents[0].set_volume(contents[0].get_volume() - .1/split.get_density())
			print("After split volume: " + str(contents[0].volume))
		return split

func TryActIndependently():
	pass

func _on_btnDispense_pressed():
	
	var volDispensed = $ScoopulaMenu/PanelContainer/sliderDispenseQty.value / contents[0].density
	
	#Add contents to receiving object
	var contentToDispense = contents[0].duplicate()
	var contentArray = []
		
	contentToDispense.set_volume(volDispensed)
	contentArray.append(contentToDispense)
	targetObj.AddContents(contentArray)
	
	#Update current volume remaining
	contents[0].volume -= volDispensed
		
	if contents[0].volume <= 0.01:
		contents.clear()
	
	LabLog.Log("Dispensed " + str(volDispensed * contentArray[0].density) + " g from scoopula")
	update_display()
	$ScoopulaMenu.hide()
