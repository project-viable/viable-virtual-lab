tool
extends SubsceneManager

# this constant exists to match the prescribed numbers with the proper result
const gel_ratio_conv_const = 30 #26.6666667

# extra images for comb variant
var empty_comb_img = null
var filled_comb_img = null
var comb_slots = 5
var dna_contents = []
var gel_has_wells = false

export (Texture) var filled_image = null
var empty_image = null
var contents = []

var hasComb = false
var combObject = null

func LabObjectReady():
	empty_comb_img = preload('res://Images/Gel_Tray_comb_empty.png')
	filled_comb_img = preload('res://Images/Gel_Tray_comb_gel.png')
	filled_image = preload('res://Images/Gel_Tray_filled.png')
	empty_image = preload('res://Images/Gel_Tray_empty.png')

func update_display():
	# static change from "empty" to "filled" for now
	if(hasComb):
		# variants with the gel comb
		if(len(contents) > 0):
			if(filled_comb_img != null):
				$Sprite.texture = filled_comb_img
		else:
			$Sprite.texture = empty_comb_img
	else:
		# variants without the gel comb
		if(len(contents) > 0):
			if(filled_image != null):
				$Sprite.texture = filled_image
		else:
			$Sprite.texture = empty_image

func _on_ChillButton_pressed():
	if contents:
		chill(1)
		gel_has_wells = hasComb
		
		#spit the comb back out
		get_parent().add_child(combObject)
		hasComb = false
		update_display()
		
		LabLog.Log("Chilled", false, true)
		$Subscene/Border/ChillButton.hide() #TODO: Make it possible to hit the button mroe than once?

func add_dna(dna):
	print("Added DNA to gel boat")
	dna_contents.append(dna)
	print("DNA functions: " + str(dna.get_class()))
	print("New DNA contents: " + str(dna_contents))

func calculate_positions():
	var band_positions = []
	var slot = 0
	for dna in dna_contents:
		if dna.is_in_group('DNA'):
			var temp_array = []
			for size in dna.get_particle_sizes():
				# Multiply total run time/ideal run time + extra to make percentage, multiply by viscosity and gel ratio, divide by size
				var distance = ((contents[0].total_run_time/(40)) * (contents[0].viscosity) * (contents[0].gel_ratio * gel_ratio_conv_const))/size
				temp_array.append(distance)
			band_positions.append(temp_array)
			slot = slot + 1
	return band_positions

func gel_status():
	return [self, gel_has_wells]

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
		
		if not new_content.is_in_group('DNA'):
			continue
			
		if hasComb:
			print("The comb is in the way of the slots")
			LabLog.Warn("You tried to add a DNA sample to a gel while the comb is still in place. Make sure the comb has been removed before adding samples.")
			continue
		
		if contents == []:
			print("There is not gel in the mold")
			continue
			
		if not contents[0].is_in_group('Gel'):
			print("A substance that is not gel is in the mold")
			continue
			
		if !contents[0].cooled:
			print("Gel has not been cooled")
			continue
			
		if not gel_has_wells:
			print("There are no comb slots in the gel")
			LabLog.Warn("You tried to add a DNA sample to a gel with no wells. Make sure a gel comb is placed into the gel while it cools so the wells can form.")
			continue
		if dna_contents.size() < comb_slots:
			add_dna(new_content)
	print("Added contents "+str(contents)+" to container")
	update_weight()
	update_display()

func dispose():
	contents.clear()
	update_display()
	
	# clear the gel variables as well
	dna_contents.clear()
	gel_has_wells = false

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

func update_weight():
	var overall_weight = 9.8 #self.mass
	for content in contents:
		if(content.is_in_group("Weighable")):
			overall_weight += content.get_mass()
	weight = overall_weight

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

func CheckContents(group):
	print('Checking for '+group)
	var check_results = []
	for content in contents:
		check_results.append(content.is_in_group(group))
	return check_results

func TryInteract(others):
	for other in others:
		if other.is_in_group("Gel Comb"):
			combObject = other
			combObject.get_parent().remove_child(combObject)
			hasComb = true
			update_display()
			return true
		elif other.is_in_group('GelImager'):
			if(hasComb):
				LabLog.Warn("You didn't remove the comb from the gel before imaging the gel. The experiment can't continue.")
			else:
				other.AddContents(self)
		elif(other.is_in_group('Container')):
			# transfer contents to another container
			other.AddContents(TakeContents())
			return true
		elif other is Pipette:
			AdoptNode(others[0])
			ShowSubscene()
			return true

func TryActIndependently():
	if not subsceneActive: ShowSubscene()
	return true
