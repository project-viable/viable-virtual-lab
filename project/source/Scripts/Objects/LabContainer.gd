@tool
extends LabObject
class_name LabContainer

# This container models a container (like a flask) that can be emptied of its contents.

var contents = []

func LabObjectReady():
	update_display()

func TryInteract(others):
	for other in others:
		if(other.is_in_group('Container')):
			# transfer contents to another container
			other.AddContents(TakeContents())
			return true
	
	return false

func TryActIndependently():
	$FollowMenu.visible = !$FollowMenu.visible
	return true

func CheckContents(group):
	print('Checking for '+group)
	var check_results = []
	for content in contents:
		check_results.append(content.is_in_group(group))
	return check_results

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
		return [dispensed_subst]
	
	var all_contents = contents.duplicate(true)
	contents.clear()
	print("Emptied container of its contents")
	update_weight()
	update_display()
	return all_contents

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
	update_display()

func update_weight():
	var overall_weight = 0 #self.mass
	for content in contents:
		if(content.is_in_group("Weighable")):
			overall_weight += content.get_mass()
	weight = overall_weight

func heat(heatTime):
	print("LabContainer is being heated")
	# pass heating along to the container's contents
	for content in contents:
		if(content.is_in_group("Heatable")):
			content.heat(heatTime)

func chill(chillTime):
	# pass chilling along to the container's contents
	for content in contents:
		if(content.is_in_group("Chillable")):
			content.chill(chillTime)

func run_current(voltage, time):
	# pass current along to the container's contents
	for content in contents:
		if(content.is_in_group("Conductive")):
			content.run_current(voltage, time)

func mix():
	# mix together all mixable contents
	var mixable_contents = []
	var removal_indices = []
	for i in range(len(contents)):
		if(contents[i].is_in_group("Mixable")):
			mixable_contents.append(contents[i])
			removal_indices.append(i)
	
	var mix_result = get_node('../MixManager').mix(mixable_contents)
	if(mix_result != null):
		# prevent index-shifting by resolving removals in reverse-sorted order
		removal_indices.sort()
		removal_indices.invert()
		
		for index in removal_indices:
			contents.pop_at(index)
		
		AddContents([mix_result])
	update_weight()

func dispose():
	contents.clear()
	update_display()

func update_display():
	# static change from "empty" to "filled" for now
	$FillSprite.visible = (len(contents) > 0)
	
	###Now we need to calculate the average color of our contents:
	if len(contents) > 0:
		var r = 0
		var g = 0
		var b = 0
		var a = 0
		var volume = 0
		
		for content in contents:
			r += Color(content.color).r * content.volume
			g += Color(content.color).g * content.volume
			b += Color(content.color).b * content.volume
			volume += content.volume
				
		if volume > 0:
			r = r/volume
			g = g/volume
			b = b/volume
			a = 1
		else:
			a = 0	
		
		
		$FillSprite.modulate = Color(r, g, b, a)

func _on_Button_pressed():
	mix()
	$FollowMenu.visible = false
