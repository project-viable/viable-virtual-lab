@tool
extends LabObject
class_name LabContainer

# This container models a container (like a flask) that can be emptied of its contents.

var contents: Array[Substance] = []

func LabObjectReady() -> void:
	update_display()

func TryInteract(other_substance: Array[Substance]) -> bool:
	for substance in other_substance:
		if(substance.is_in_group('Container')):
			# transfer contents to another container
			substance.AddContents(TakeContents())
			return true
	
	return false

func TryActIndependently() -> bool:
	$FollowMenu.visible = !$FollowMenu.visible
	return true

func CheckContents(group: String) -> Array[bool]:
	print('Checking for '+group)
	var check_results: Array[bool] = []
	for content in contents:
		check_results.append(content.is_in_group(group))
	return check_results

func TakeContents(volume: int = -1) -> Array[Substance]:
	# check for whether we can distribute the contents by volume
	if(volume != -1 && len(contents) == 1):
		if(volume >= contents[0].volume):
			return [contents.pop_front()]
		
		# make a duplicate substance with the desired volume
		var dispensed_subst:= contents[0].duplicate()
		var original_props: Dictionary = contents[0].get_properties()
		var dispensed_props:= original_props.duplicate()
		
		var remaining_volume: int = contents[0].volume - volume
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

func AddContents(new_contents: Array[Substance]) -> void:
	for new_content: Node in new_contents:
		var match_found: bool = false
		
		for chk_content: Node in contents:
			if(new_content.name == chk_content.name):
				# combine the two contents together
				match_found = true
				print("Combining substances "+str(new_content)+" and "+str(chk_content))
				var props: Dictionary = chk_content.get_properties()
				
				var current_vol: int = props["volume"]
				var new_vol: int = new_content.get_properties()["volume"]
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

func update_weight() -> void:
	var overall_weight:= 0 #self.mass
	for content in contents:
		if(content.is_in_group("Weighable")):
			overall_weight += content.get_mass()
	mass = overall_weight

func heat(heatTime: float) -> void:
	print("LabContainer is being heated")
	# pass heating along to the container's contents
	for content in contents:
		if(content.is_in_group("Heatable")):
			content.heat(heatTime)

func chill(chillTime: float) -> void:
	# pass chilling along to the container's contents
	for content in contents:
		if(content.is_in_group("Chillable")):
			content.chill(chillTime)

func run_current(voltage: float, time: float) -> void:
	# pass current along to the container's contents
	for content in contents:
		if(content.is_in_group("Conductive")):
			content.run_current(voltage, time)

func mix() -> void:
	# mix together all mixable contents
	var mixable_contents: Array[Substance] = []
	var removal_indices: Array[int] = []
	for i in range(len(contents)):
		if(contents[i].is_in_group("Mixable")):
			mixable_contents.append(contents[i])
			removal_indices.append(i)
	
	var mix_result: Array[Substance] = get_node('../MixManager').mix(mixable_contents)
	if(mix_result != null):
		# prevent index-shifting by resolving removals in reverse-sorted order
		removal_indices.sort()
		removal_indices.reverse()
		
		for index: int in removal_indices:
			contents.pop_at(index)
		
		AddContents(mix_result)
	update_weight()

func dispose() -> void:
	contents.clear()
	update_display()

func update_display() -> void:
	# static change from "empty" to "filled" for now
	$FillSprite.visible = (len(contents) > 0)
	
	###Now we need to calculate the average color of our contents:
	if len(contents) > 0:
		var r: float = 0
		var g: float = 0
		var b: float = 0
		var a: float = 0
		var volume: float = 0
		
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

func _on_Button_pressed() -> void:
	mix()
	$FollowMenu.visible = false
