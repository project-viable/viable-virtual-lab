@tool
extends SubsceneManager
class_name GelMoldSubsceneManager

# this constant exists to match the prescribed numbers with the proper result
const gel_ratio_conv_const = 30 #26.6666667

# extra images for comb variant
var empty_comb_img: Texture2D = null
var filled_comb_img: Texture2D = null

# TODO (update): This is unused; remove it.
var comb_slots: int = 5
@onready var dna_contents: Array[DNASubstance] = [null, null, null, null, null, null]
var gel_has_wells: bool = false

@export var filled_image: Texture2D = null
var empty_image: Texture2D = null
var contents: Array[Substance] = []

var has_comb: bool = false
var comb_object: LabObject = null

var subscene_empty_img: Texture2D = preload("res://Images/Gel_Tray_empty_zoomed.png")
var subscene_full_img: Texture2D = preload('res://Images/Gel_Tray_filled_zoomed.png')
var subscene_full_wells_img: Texture2D = preload('res://Images/Gel_Tray_filled_wells_zoomed.png')
var subscene_full_comb_img: Texture2D = preload('res://Images/Gel_Tray_comb_gel_zoomed.png')
var subscene_empty_comb_img: Texture2D = preload('res://Images/Gel_Tray_comb_empty_zoomed.png')
var subscene_gel_bg: TextureRect = null

func lab_object_ready() -> void:
	empty_comb_img = preload('res://Images/Gel_Tray_comb_empty.png')
	filled_comb_img = preload('res://Images/Gel_Tray_comb_gel.png')
	filled_image = preload('res://Images/Gel_Tray_filled.png')
	empty_image = preload('res://Images/Gel_Tray_empty.png')
	
	subscene_gel_bg = $Subscene/Border/Background2
	$Subscene/PipetteProxies.hide()
	update_display()

func update_display() -> void:
	# static change from "empty" to "filled" for now
	if(has_comb):
		# variants with the gel comb
		if(len(contents) > 0):
			if(filled_comb_img != null):
				$Sprite2D.texture = filled_comb_img
			subscene_gel_bg.texture = subscene_full_comb_img
		else:
			$Sprite2D.texture = empty_comb_img
			subscene_gel_bg.texture = subscene_empty_comb_img
	else:
		# variants without the gel comb
		if(len(contents) > 0):
			if(filled_image != null):
				$Sprite2D.texture = filled_image
			
			if gel_has_wells:
				subscene_gel_bg.texture = subscene_full_wells_img
				$Subscene/PipetteProxies.show()
			else:
				subscene_gel_bg.texture = subscene_full_img
		else:
			$Sprite2D.texture = empty_image
			subscene_gel_bg.texture = subscene_empty_img

func _on_ChillButton_pressed() -> void:
	if contents:
		chill(1)
		gel_has_wells = has_comb

		update_display()
		
		LabLog.log("Chilled", false, true)
		$Subscene/Border/ChillButton.hide() #TODO: Make it possible to hit the button mroe than once?

func add_dna(dna: DNASubstance, well: int) -> void:
	print("Added DNA to gel boat")
	dna_contents[well] = dna
	print("DNA functions: " + str(dna.get_class()))
	print("New DNA contents: " + str(dna_contents))

# TODO (update): Since Godot doesn't support nested typed arrays, we should consider wrapping the
# inner array in a class to maintain static-ish typing.
#
# The return type should be `Array[Array[float]]`.
func calculate_positions() -> Array[Array]:
	var band_positions: Array[Array] = []
	var slot := 0
	for dna in dna_contents:
		var temp_array: Array[float] = []

		# TODO (update): remove this check, since `dna` should always be a DNA substance and
		# therefore this will always be true.
		if dna and dna.is_in_group('DNA'):
			for size: float in dna.get_particle_sizes():
				# Multiply total run time/ideal run time + extra to make percentage, multiply by viscosity and gel ratio, divide by size
				#var distance = ((contents[0].total_run_time/(40)) * (contents[0].viscosity) * (contents[0].gel_ratio * gel_ratio_conv_const))/(size / 300)

				var distance: float = (contents[0].total_run_time/(20)) * (673.6 * pow(2.7183, -0.000773 * size) + 480.6 * pow(2.7186, -0.00002189 * size)) / 1500				
				
				temp_array.append(distance)
		band_positions.append(temp_array)
		slot = slot + 1
	return band_positions

# TODO (update): The "intended" type of this is actually something like
# `Tuple[GelMoldSubsceneManager, bool]`. But since Godot doesn't have tuples, this might be better
# to replace with a class.
func gel_status() -> Array[Variant]:
	return [self, gel_has_wells]

func add_contents(new_contents: Array[Substance]) -> void:
	for new_content in new_contents:
		var match_found := false
		
		for chk_content in contents:
			if(new_content.name == chk_content.name):
				# combine the two contents together
				match_found = true
				print("Combining substances "+str(new_content)+" and "+str(chk_content))
				var props := chk_content.get_properties()
				
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
		
		if not new_content.is_in_group('DNA'):
			continue
			
		if has_comb:
			print("The comb is in the way of the slots")
			LabLog.warn("You tried to add a DNA sample to a gel while the comb is still in place. Make sure the comb has been removed before adding samples.")
			continue
		
		if contents == []:
			print("There is not gel in the mold")
			LabLog.warn("There is no gel in the mold.")
			continue
			
		if not contents[0].is_in_group('Gel'):
			print("A substance that is not gel is in the mold")
			LabLog.warn("A substance other than a gel is in the mold.")
			continue
			
		if !contents[0].cooled:
			print("Gel has not been cooled")
			LabLog.warn("Gel has not been cooled yet.")
			continue
			
		if not gel_has_wells:
			print("There are no comb slots in the gel")
			LabLog.warn("You tried to add a DNA sample to a gel with no wells. Make sure a gel comb is placed into the gel while it cools so the wells can form.")
			continue
	print("Added contents "+str(contents)+" to container")
	update_weight()
	update_display()

func dispose() -> void:
	contents.clear()
	update_display()
	
	# clear the gel variables as well
	dna_contents.clear()
	gel_has_wells = false

func chill(chill_time: float) -> void:
	# pass chilling along to the container's contents
	for content in contents:
		if(content.is_in_group("Chillable")):
			content.chill(chill_time)

func run_current(voltage: float, time: float) -> void:
	# pass current along to the container's contents
	for content in contents:
		if(content.is_in_group("Conductive")):
			content.run_current(voltage, time)

func update_weight() -> void:
	var overall_weight := 9.8 #self.mass
	for content in contents:
		if(content.is_in_group("Weighable")):
			overall_weight += content.get_mass()

	mass = overall_weight

func take_contents(volume: float = -1) -> Array[Substance]:
	# check for whether we can distribute the contents by volume
	if(volume != -1 && len(contents) == 1):
		if(volume >= contents[0].volume):
			return [contents.pop_front()]
		
		# make a duplicate substance with the desired volume
		var dispensed_subst := contents[0].duplicate()
		var original_props := contents[0].get_properties()
		var dispensed_props := original_props.duplicate()
		
		var remaining_volume := contents[0].volume - volume
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
	
	var all_contents := contents.duplicate(true)
	contents.clear()
	print("Emptied container of its contents")
	update_weight()
	update_display()
	return all_contents

func check_contents(group: StringName) -> Array[bool]:
	print('Checking for '+group)
	var check_results: Array[bool] = []
	for content in contents:
		check_results.append(content.is_in_group(group))
	return check_results

func try_interact(others: Array[LabObject]) -> bool:
	for other in others:
		if other.is_in_group("Gel Comb"):
			comb_object = other
			comb_object.get_parent().remove_child(comb_object)
			has_comb = true
			update_display()
			return true
		# TODO (update): There is no 'GelImager' group, but there *is* a 'Gel Imager' group. This
		# means that this never gets called.
		elif other.is_in_group('GelImager'):
			if(has_comb):
				LabLog.warn("You didn't remove the comb from the gel before imaging the gel. The experiment can't continue.")
		elif(other.is_in_group('Container')):
			# transfer contents to another container
			other.add_contents(take_contents())
			return true
	
	return false

func try_act_independently() -> bool:
	if not subscene_active: show_subscene()
	if has_comb:
		$Subscene/Border/RemoveComb.show()
	else:
		$Subscene/Border/RemoveComb.hide()
	return true

func _on_RemoveComb_pressed() -> void:
	if has_comb:
		get_parent().add_child(comb_object)
		comb_object.position.x -= 100
		has_comb = false
		update_display()
		$Subscene/Border/RemoveComb.hide()

func gel_mold_info() -> Dictionary:
	return {
		"hasComb": has_comb,
		"hasWells": gel_has_wells,
	}
