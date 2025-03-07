extends LabContainer

# TODO (update): `dispense_mode` isn't used anywhere. Remove it or figure out what it's supposed to
# do.
var dispense_mode: int = 0
var split_substance: Array[Substance] = [] 

# TODO (update): This is a substance container, and I would *like* to give this a more specialized
# type, but there's no single class that all containers derive from other than `LabObject`. We
# should find a way to fix this, but that's kind of complicated.
var target_obj: LabObject = null

func try_interact(others: Array[LabObject]) -> bool:
	for other in others:#If interacting with container then we want to dispense or pick up
		if other.is_in_group("Container") or other.is_in_group("Source Container"):

			var granular_substance: bool = other.check_contents("Granular Substance").front()
			if len(contents) == 0 and granular_substance:
				# get density to determine volume taken
				var density: float = other.take_contents()[0].get_properties()['density']
				
				contents.append_array(other.take_contents(1 / density)) # Take 1g of material
				if(other.is_in_group("Scale")):
					other.update_weight()
				print("Added contents")
				if contents != []:
					LabLog.log("Added " + contents[0].name + " to scoopula.")
				update_display()
				return true
			else:
				if(!contents.is_empty()):
					var content_name := contents[0].name
					
					#Show menu
					$ScoopulaMenu.popup()
					$ScoopulaMenu.global_position = global_position
					$ScoopulaMenu/PanelContainer/sliderDispenseQty.max_value = contents[0].volume
					
					target_obj = other
						#split_substance.append(split_contents())
						#other.add_contents(split_substance)
				update_display()
				return true
	return false

func split_contents() -> Substance:
	if(contents.is_empty()):
		print("empty")
		return null
	else:
		print("array check")
		var split := contents[0].duplicate()
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

func try_act_independently() -> bool:
	return false

func _on_btnDispense_pressed() -> void:
	
	var vol_dispensed: float = $ScoopulaMenu/PanelContainer/sliderDispenseQty.value / contents[0].density
	
	#Add contents to receiving object
	var content_to_dispense: Substance = contents[0].duplicate()
	var content_array: Array[Substance] = []
		
	content_to_dispense.set_volume(vol_dispensed)
	content_array.append(content_to_dispense)
	target_obj.add_contents(content_array)
	
	#Update current volume remaining
	contents[0].volume -= vol_dispensed
		
	if contents[0].volume <= 0.01:
		contents.clear()
	
	LabLog.log("Dispensed " + str(vol_dispensed * content_array[0].density) + " g from scoopula")
	update_display()
	$ScoopulaMenu.hide()
