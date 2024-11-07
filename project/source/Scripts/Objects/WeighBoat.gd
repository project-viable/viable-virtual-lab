extends LabContainer

var substance = null

func _ready():
	pass # LabContainer does not have a _ready() function

func TryActIndependently():
	pass

func AddContents(new_contents):
	for new_content in new_contents:
		var match_found = false
		for chk_content in contents:
			if(new_content.name == chk_content.name):
				# combine the two contents together
				match_found = true
				print("Combining substances "+str(new_content)+" and "+str(chk_content))
				var props = chk_content.get_properties()
				var current_vol = props["volume"]
				var new_vol = new_content.get_properties()["volume"]
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
	scale_check()
	
func TakeContents(volume = -1):
	# check for whether we can distribute the contents by volume
	if(volume != -1 && len(contents) == 1):
		if(volume >= contents[0].volume):
			return [contents.pop_front()]
		
		# make a duplicate substance with the desired volume
		var dispensed_subst = contents[0].duplicate()
		var original_props = contents[0].get_properties()
		var dispensed_props = original_props.duplicate()
		
		var remaining_volume = contents[0].volume - volume
		dispensed_props["volume"] = volume
		original_props["volume"] = remaining_volume
		
		# write the new volume values to the substances
		contents[0].init_created(original_props)
		dispensed_subst.init_created(dispensed_props)
		
		print("Dispensed "+str(dispensed_subst.volume)+"mL of the contents")
		print("Contents now have "+str(contents[0].volume)+"mL of the substance")
		update_weight()
		update_display()
		scale_check()
		return [dispensed_subst]
	
	var all_contents = contents.duplicate(true)
	contents.clear()
	print("Emptied container of its contents")
	update_weight()
	update_display()
	scale_check()
	return all_contents
	
func scale_check():
	for object in $Area2D.get_overlapping_bodies():
		if(object.is_in_group("Scale")):
			object.UpdateWeight()
			return true
	return false
			
func update_weight():
	weight = .4 #self mass
	for object in contents:
		weight += object.get_mass()

func dispose():
	contents.clear()
	update_display()
	weight = .4
