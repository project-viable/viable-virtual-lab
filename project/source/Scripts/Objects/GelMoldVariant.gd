extends LabContainer

# this constant exists to match the prescribed numbers with the proper result
const gel_ratio_conv_const = 30 #26.6666667

# extra images for comb variant
var empty_comb_img = null
var filled_comb_img = null
var comb_slots = 5
var dna_contents = []
var gel_has_wells = false

func _ready():
	empty_comb_img = preload('res://Images/Gel_Tray_comb_empty.png')
	filled_comb_img = preload('res://Images/Gel_Tray_comb_gel.png')

func update_display():
	# static change from "empty" to "filled" for now
	if($CombSlot.filled()):
		# variants with the gel comb
		if(len(contents) > 0):
			if(filled_image != null):
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

func slot_filled(slot, object):
	update_display()
	object.visible = false

func slot_emptied(slot, object):
	object.visible = true
	call_deferred("update_display")

func _on_Button_pressed():
	chill(1)
	$FollowMenu.visible = false
	
	gel_has_wells = $CombSlot.filled()

func add_dna(dna):
	# we can only add DNA if the gel has wells in it
	if(!gel_has_wells):
		LabLog.Warn("You tried to add a DNA sample to a gel with no wells. Make sure a gel comb is placed into the gel while it cools so the wells can form.")
		return
	
	if($CombSlot.filled()):
		LabLog.Warn("You tried to add a DNA sample to a gel while the comb is still in place. Make sure the comb has been removed before adding samples.")
		return
	
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

func TryInteract(others):
	for other in others:
		if other.is_in_group('GelImager'):
			if($CombSlot.filled()):
				LabLog.Warn("You didn't remove the comb from the gel before imaging the gel. The experiment can't continue.")
			else:
				other.AddContents(self)
		elif(other.is_in_group('Container')):
			# transfer contents to another container
			other.AddContents(TakeContents())
			return true

func TryActIndependently():
	if($CombSlot.filled() && gel_has_wells):
		LabLog.Error("You didn't remove the comb from the gel before running. The experiment can't continue.")
	
	$FollowMenu.visible = !$FollowMenu.visible
	return true

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
		
		if new_content.is_in_group('DNA'):
			if not $CombSlot.filled():
				if contents != []:
					if contents[0].is_in_group('Gel'):
						if contents[0].cooled:
							if gel_has_wells:
								if dna_contents.size() < comb_slots:
									add_dna(new_content)
								else:
									print("All comb slots are full")
							else:
								print("There are no comb slots in the gel")
						else:
							print("Gel has not been cooled")
					else:
						print("A substance that is not gel is in the mold")
				else:
					print("There is not gel in the mold")
			else:
				print("The comb is in the way of the slots")
		elif(!match_found):
			contents.append(new_content)
	
	print("Added contents "+str(contents)+" to container")
	update_weight()
	update_display()

func dispose():
	contents.clear()
	update_display()
	
	# clear the gel variables as well
	dna_contents.clear()
	gel_has_wells = false

#func TakeContents(volume = -1):
#	if contents[0].is_in_group('Gel'):
#		# Can't take gel out after it has been cooled
#		if contents[0].cooled == false:
#			return self.TakeContents(volume)
#		else:
#			print("Gel has been cooled, cannot remove gel")
#	else:
#		return self.TakeContents(volume)
