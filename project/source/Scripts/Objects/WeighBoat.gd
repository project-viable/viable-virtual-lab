extends LabContainer

# Mass of the weigh boat by itself.
# TODO: This mass is supposed to represent mass in grams, but Godot's mass is in kilograms.
@onready var base_mass: float = mass

func try_act_independently() -> bool:
	return false

func add_contents(new_contents: Array[Substance]) -> void:
	for new_content: Substance in new_contents:
		var match_found: bool = false
		for chk_content: Substance in contents:
			if(new_content.name == chk_content.name):
				# combine the two contents together
				match_found = true
				print("Combining substances "+str(new_content)+" and "+str(chk_content))
				var props: Dictionary = chk_content.get_properties()
				var current_vol: float = props["volume"]
				var new_vol: float = new_content.get_properties()["volume"]
				props["volume"] = current_vol + new_vol
				#var vol_ratio = (current_vol / new_vol)
				#props["density"] = (vol_ratio * props["density"]) + ((1.0 - vol_ratio) * new_content.get_properties()["density"])
				chk_content.init_created(props)
				print("Final volume is "+str(chk_content.volume))
				
				break
		if(!match_found):
			contents.append(new_content)
	
	print("Added contents "+str(contents)+" to container")
	update_weight()
	print("Current weight " + str(mass))
	update_display()

func take_contents(volume: float = -1.0) -> Array[Substance]:
	# check for whether we can distribute the contents by volume
	if(volume != -1 && len(contents) == 1):
		if(volume >= contents[0].volume):
			return [contents.pop_front()]
		
		# make a duplicate substance with the desired volume
		var dispensed_subst: Substance = contents[0].duplicate()
		var original_props: Dictionary = contents[0].get_properties()
		var dispensed_props: Dictionary = original_props.duplicate()
		
		var remaining_volume: float = contents[0].volume - volume
		dispensed_props["volume"] = volume
		original_props["volume"] = remaining_volume
		
		# write the new volume values to the substances
		contents[0].init_created(original_props)
		dispensed_subst.init_created(dispensed_props)
		
		print("Dispensed "+str(dispensed_subst.volume)+"mL of the contents")
		print("Contents now have "+str(contents[0].volume)+"mL of the substance")
		update_weight()
		update_display()
		return [dispensed_subst]
	
	var all_contents: Array[Substance] = contents.duplicate(true)
	contents.clear()
	print("Emptied container of its contents")
	update_weight()
	update_display()
	return all_contents

func update_weight() -> void:
	mass = base_mass
	for object: Substance in contents:
		mass += object.get_mass()

func dispose() -> void:
	contents.clear()
	update_display()
	mass = base_mass
