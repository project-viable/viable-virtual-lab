extends Imager

var base_gel_sprite: Sprite2D = null #replace with actual base gel mold sprite from top down view
var base_wells_sprite: Sprite2D = null
var gel_band: Sprite2D = null
var gel: LabBody = null

func on_gel_inserted() -> void:
	base_gel_sprite = $GelRigTopView
	base_wells_sprite = $GelWellTopViewLadderMultiple
	
	if get_UV_state() == true:
		print("starting imaging")
		if $AttachmentInteractableArea.object_placed != null:
			gel = $AttachmentInteractableArea.object_placed
			display_gel_bands()
		else:
			print("nothing is inside the imager.")
	else:
		display_blank_gel_bands()
		print("UV light is off. Gel will be blank")

func _on_uv_light_pressed() -> void:
	if not UV_state:
		UV_state = true
		print("UV light is now on")
	else:
		UV_state = false	
		print("UV light is now off")

func on_gel_removed() -> void:
	if $AttachmentInteractableArea.contained_object != null:
		base_gel_sprite.visible = false
		base_wells_sprite.visible = false
		for i:int in gel.num_wells():
			var well: ContainerComponent = gel.get_well(i)
			well.gel_band_sprites.clear()
		$AttachmentInteractableArea.remove_object()
	else:
		for body: LabBody in  $AttachmentInteractableArea.get_overlapping_bodies():
			if body.name == "GelMold":
				$AttachmentInteractableArea.contained_object = body
				print("there is something already in the imager")

func display_blank_gel_bands() -> void:
	base_gel_sprite.visible = true
	base_wells_sprite.visible = true
	
func analyze_gel(gel: LabBody) -> void:
	for i: int in gel.num_wells():
		var well: ContainerComponent = gel.get_well(i)
		for substance: SubstanceInstance in well.substances:
			for fragment_size: float in substance.fragment_sizes:
				#Perfect results
				if gel.gel_concentration == 0.5 and (fragment_size >= 2.0 and fragment_size <=30.0) and (gel.well_capacity >gel.well_max_capacity/2.0 and gel.well_capacity <=gel.well_max_capacity) and gel.voltage_run_time == 20.0 and gel.correct_comb_placement == true and gel.correct_gel_mixing == true and gel.correct_gel_temperature == true and gel.gel_analysis_asap == true and gel.voltage == 120:
					gel_band = $GelWellTopViewPerfect9Slice.duplicate()
					well.gel_band_sprites.append(gel_band)
					gel_band.position = substance.position
					base_gel_sprite.visible = true
					base_wells_sprite.visible = true
					print("perfect! Here's a perfect gel band sprite with long ladders for well ", i, ", fragment size, ",fragment_size, " !")
					continue
				if gel.gel_concentration == 0.7 and (fragment_size >= 0.8 and fragment_size <=12.0) and (gel.well_capacity >gel.well_max_capacity/2.0 and gel.well_capacity <=gel.well_max_capacity) and gel.voltage_run_time == 20.0 and gel.correct_comb_placement == true and gel.correct_gel_mixing == true and gel.correct_gel_temperature == true and gel.gel_analysis_asap == true and gel.voltage == 120:
					gel_band = $GelWellTopViewPerfect9Slice.duplicate()
					well.gel_band_sprites.append(gel_band)
					gel_band.position = substance.position
					base_gel_sprite.visible = true
					base_wells_sprite.visible = true
					print("perfect! Here's a perfect gel band sprite with long ladders for well ", i, ", fragment size, ",fragment_size, " !")
					continue
				if gel.gel_concentration == 1.0 and (fragment_size >= 0.4 and fragment_size <=8.0) and (gel.well_capacity >gel.well_max_capacity/2.0 and gel.well_capacity <=gel.well_max_capacity) and gel.voltage_run_time == 20.0 and gel.correct_comb_placement == true and gel.correct_gel_mixing == true and gel.correct_gel_temperature == true and gel.gel_analysis_asap == true and gel.voltage == 120:
					gel_band = $GelWellTopViewPerfect9Slice.duplicate()
					well.gel_band_sprites.append(gel_band)
					gel_band.position = substance.position
					base_gel_sprite.visible = true
					base_wells_sprite.visible = true
					print("perfect! Here's a perfect gel band sprite with long ladders for well ", i, ", fragment size, ",fragment_size, " !")
					continue
				if gel.gel_concentration == 1.2 and (fragment_size >= 0.3 and fragment_size <=7.0) and (gel.well_capacity >gel.well_max_capacity/2.0 and gel.well_capacity <=gel.well_max_capacity) and gel.voltage_run_time == 20.0 and gel.correct_comb_placement == true and gel.correct_gel_mixing == true and gel.correct_gel_temperature == true and gel.gel_analysis_asap == true and gel.voltage == 120:
					gel_band = $GelWellTopViewPerfect.duplicate()
					well.gel_band_sprites.append(gel_band)
					gel_band.position = substance.position
					base_gel_sprite.visible = true
					base_wells_sprite.visible = true
					print("perfect! Here's a perfect gel band sprite with short ladders for well ", i, ", fragment size, ",fragment_size, " !")
					continue
				if gel.gel_concentration == 1.5 and (fragment_size >= 0.2 and fragment_size <=3.0) and (gel.well_capacity >gel.well_max_capacity/2.0 and gel.well_capacity <=gel.well_max_capacity) and gel.voltage_run_time == 20.0 and gel.correct_comb_placement == true and gel.correct_gel_mixing == true and gel.correct_gel_temperature == true and gel.gel_analysis_asap == true and gel.voltage == 120:
					gel_band = $GelWellTopViewPerfect.duplicate()
					well.gel_band_sprites.append(gel_band)
					gel_band.position = substance.position
					base_gel_sprite.visible = true
					base_wells_sprite.visible = true
					print("perfect! Here's a perfect gel band sprite with short ladders for well ", i, ", fragment size, ",fragment_size, " !")
					continue
				if gel.gel_concentration == 2.0 and (fragment_size >= 0.1 and fragment_size <=2.0) and (gel.well_capacity >gel.well_max_capacity/2.0 and gel.well_capacity <=gel.well_max_capacity) and gel.voltage_run_time == 20.0 and gel.correct_comb_placement == true and gel.correct_gel_mixing == true and gel.correct_gel_temperature == true and gel.gel_analysis_asap == true and gel.voltage == 120:
					gel_band = $GelWellTopViewPerfect.duplicate()
					well.gel_band_sprites.append(gel_band)
					gel_band.position = substance.position
					base_gel_sprite.visible = true
					base_wells_sprite.visible = true
					print("perfect! Here's a perfect gel band sprite with short ladders for well ", i, ", fragment size, ",fragment_size, " !")
					continue
				#Conditions for singular well invisible gel bands
				if gel.well_capacity <=gel.well_max_capacity/2.0:
					gel_band = null
					well.gel_band_sprites.append(gel_band)
					gel_band.position = substance.position
					base_gel_sprite.visible = true
					base_wells_sprite.visible = true
					print("well capacity not full enough gel sprite will be blank")
					continue
				# Conditions for fuzzy or diffused gel bands
				if gel.voltage <120 and fragment_size >= 0.1:
					gel_band = $GelWellTopViewDiffused9Slice.duplicate()
					well.gel_band_sprites.append(gel_band)
					gel_band.position = substance.position
					base_gel_sprite.visible = true
					base_wells_sprite.visible = true
					print("voltage too low! fragment of size", fragment_size, " will have a long fuzzy band")
					continue
				if gel.gel_concentration <120 and fragment_size < 0.1:
					gel_band = $GelWellTopViewDiffused.duplicate()
					well.gel_band_sprites.append(gel_band)
					gel_band.position = substance.position
					base_gel_sprite.visible = true
					base_wells_sprite.visible = true
					print("voltage too low! fragment of size", fragment_size, " will have a short fuzzy band")
					continue
				if gel.voltage_run_time <20 and fragment_size >= 0.1:
					gel_band = $GelWellTopViewDiffused9Slice.duplicate()
					well.gel_band_sprites.append(gel_band)
					gel_band.position = substance.position
					base_gel_sprite.visible = true
					base_wells_sprite.visible = true
					print("voltage too low! fragment of size", fragment_size, " will have a long fuzzy band")
					continue
				if gel.voltage_run_time <20 and fragment_size < 0.1:
					gel_band = $GelWellTopViewDiffused9Slice.duplicate()
					well.gel_band_sprites.append(gel_band)
					gel_band.position = substance.position
					base_gel_sprite.visible = true
					base_wells_sprite.visible = true
					print("voltage too low! fragment of size", fragment_size, " will have a long fuzzy band")
					continue
				if gel.gel_concentration < 2.0 and fragment_size >= 0.1 and fragment_size <=2.0:
					gel_band = $GelWellTopViewDiffused.duplicate()
					well.gel_band_sprites.append(gel_band)
					gel_band.position = substance.position
					base_gel_sprite.visible = true
					base_wells_sprite.visible = true
					print("gel concentration too low for 0.1kb-2kb dna size! fragment of size", fragment_size, " will have a short fuzzy band")
					continue
				if gel.gel_concentration >2.0 and fragment_size >= 0.1 and fragment_size <=2.0:
					gel_band = $GelWellTopViewDiffused.duplicate()
					well.gel_band_sprites.append(gel_band)
					gel_band.position = substance.position
					base_gel_sprite.visible = true
					base_wells_sprite.visible = true
					print("gel concentration too high for 0.1kb-2kb dna size! fragment of size", fragment_size, " will have a short fuzzy band")
					continue
				if gel.gel_concentration < 1.5 and fragment_size >= 0.2 and fragment_size <=3.0:
					gel_band = $GelWellTopViewDiffused.duplicate()
					well.gel_band_sprites.append(gel_band)
					gel_band.position = substance.position
					base_gel_sprite.visible = true
					base_wells_sprite.visible = true
					print("gel concentration too low for 0.2kb-3kb dna size! fragment of size", fragment_size, " will have a short fuzzy band")
					continue
				if gel.gel_concentration >1.5 and fragment_size >= 0.2 and fragment_size <=3.0:
					gel_band = $GelWellTopViewDiffused.duplicate()
					well.gel_band_sprites.append(gel_band)
					gel_band.position = substance.position
					base_gel_sprite.visible = true
					base_wells_sprite.visible = true
					print("gel concentration too high for 0.2kb-3kb dna size! fragment of size", fragment_size, " will have a short fuzzy band")
					continue
				if gel.gel_concentration < 1.2 and fragment_size >= 0.3 and fragment_size <=7.0:
					gel_band = $GelWellTopViewDiffused.duplicate()
					well.gel_band_sprites.append(gel_band)
					gel_band.position = substance.position
					base_gel_sprite.visible = true
					base_wells_sprite.visible = true
					print("gel concentration too low for 0.3kb-7kb dna size! fragment of size", fragment_size, " will have a short fuzzy band")
					continue
				if gel.gel_concentration >1.2 and fragment_size >= 0.3 and fragment_size <=7.0:
					gel_band = $GelWellTopViewDiffused.duplicate()
					well.gel_band_sprites.append(gel_band)
					gel_band.position = substance.position
					base_gel_sprite.visible = true
					base_wells_sprite.visible = true
					print("gel concentration too high for 0.3kb-7kb dna size! fragment of size", fragment_size, " will have a short fuzzy band")
					continue
				if gel.gel_concentration < 1.0 and fragment_size >= 0.4 and fragment_size <=8.0:
					gel_band = $GelWellTopViewDiffused9Slice.duplicate()
					well.gel_band_sprites.append(gel_band)
					gel_band.position = substance.position
					base_gel_sprite.visible = true
					base_wells_sprite.visible = true
					print("gel concentration too low for 0.4kb-8kb dna size! fragment of size", fragment_size, " will have a long fuzzy band")
					continue
				if gel.gel_concentration >1.0 and fragment_size >= 0.4 and fragment_size <=8.0:
					gel_band = $GelWellTopViewDiffused9Slice.duplicate()
					well.gel_band_sprites.append(gel_band)
					gel_band.position = substance.position
					base_gel_sprite.visible = true
					base_wells_sprite.visible = true
					print("gel concentration too high for 0.4kb-8kb dna size! fragment of size", fragment_size, " will have a long fuzzy band")
					continue
				if gel.gel_concentration < 0.7 and fragment_size >= 0.8 and fragment_size <=12.0:
					gel_band = $GelWellTopViewDiffused9Slice.duplicate()
					well.gel_band_sprites.append(gel_band)
					gel_band.position = substance.position
					base_gel_sprite.visible = true
					base_wells_sprite.visible = true
					print("gel concentration too low for 0.8kb-12kb dna size! fragment of size", fragment_size, " will have a long fuzzy band")
					continue
				if gel.gel_concentration >0.7 and fragment_size >= 0.8 and fragment_size <=12.0:
					gel_band = $GelWellTopViewDiffused9Slice.duplicate()
					well.gel_band_sprites.append(gel_band)
					gel_band.position = substance.position
					base_gel_sprite.visible = true
					base_wells_sprite.visible = true
					print("gel concentration too high for 0.8kb-12kb dna size! fragment of size", fragment_size, " will have a long fuzzy band")
					continue
				if gel.gel_concentration < 0.5 and fragment_size >= 2.0 and fragment_size <=30.0:
					gel_band = $GelWellTopViewDiffused9Slice.duplicate()
					well.gel_band_sprites.append(gel_band)
					gel_band.position = substance.position
					base_gel_sprite.visible = true
					base_wells_sprite.visible = true
					print("gel concentration too low for 2kb-30kb dna size! fragment of size", fragment_size, " will have a long fuzzy band")
					continue
				if gel.gel_concentration >0.5 and fragment_size >= 2.0 and fragment_size <=30.0:
					gel_band = $GelWellTopViewDiffused9Slice.duplicate()
					well.gel_band_sprites.append(gel_band)
					gel_band.position = substance.position
					base_gel_sprite.visible = true
					base_wells_sprite.visible = true
					print("gel concentration too high for 2kb-30kb dna size! fragment of size", fragment_size, " will have a long fuzzy band")
					continue
				if gel.gel_analysis_asap == false and fragment_size >= 8.0:
					gel_band = $GelWellTopViewDiffused.duplicate()
					well.gel_band_sprites.append(gel_band)
					gel_band.position = substance.position
					base_gel_sprite.visible = true
					base_wells_sprite.visible = true
					print("Too much time passed between electorphoresis and gel analysis! fragment of size", fragment_size, " will have a short fuzzy band")
					continue
				if gel.gel_analysis_asap == false and fragment_size < 8.0:
					gel_band = $GelWellTopViewDiffused.duplicate()
					well.gel_band_sprites.append(gel_band)
					gel_band.position = substance.position
					base_gel_sprite.visible = true
					base_wells_sprite.visible = true
					print("Too much time passed between electorphoresis and gel analysis! fragment of size", fragment_size, " will have a short fuzzy band")
					continue
				#Conditions for smiley/wavy/smeared bands
				if gel.correct_gel_temperature == false and fragment_size >= 8.0:
					gel_band = $GelWellTopViewWavy.duplicate()
					well.gel_band_sprites.append(gel_band)
					gel_band.position = substance.position
					base_gel_sprite.visible = true
					base_wells_sprite.visible = true
					print("gel heated to incorrect temperature! fragment of size", fragment_size, " will have a long wavy band")
					continue
				if gel.correct_gel_temperature == false and fragment_size < 8.0:
					gel_band = $GelWellTopViewWavy2.duplicate()
					well.gel_band_sprites.append(gel_band)
					gel_band.position = substance.position
					base_gel_sprite.visible = true
					base_wells_sprite.visible = true
					print("gel heated to incorrect temperature! fragment of size", fragment_size, " will have a short wavy band")
					continue
				if gel.correct_comb_placement == false and fragment_size >= 8.0:
					gel_band = $GelWellTopViewWavy.duplicate()
					well.gel_band_sprites.append(gel_band)
					gel_band.position = substance.position
					base_gel_sprite.visible = true
					base_wells_sprite.visible = true
					print("gel comb not placed well correctly! fragment of size", fragment_size, " will have a long wavy band")
					continue
				if gel.correct_comb_placement == false and fragment_size < 8.0:
					gel_band = $GelWellTopViewWavy2.duplicate()
					well.gel_band_sprites.append(gel_band)
					gel_band.position = substance.position
					base_gel_sprite.visible = true
					base_wells_sprite.visible = true
					print("gel comb not placed well correctly! fragment of size", fragment_size, " will have a short wavy band")
					continue
				if gel.well_capacity >gel.well_max_capacity and fragment_size >= 8.0:
					gel_band = $GelWellTopViewSmudge.duplicate()
					well.gel_band_sprites.append(gel_band)
					gel_band.position = substance.position
					base_gel_sprite.visible = true
					base_wells_sprite.visible = true
					print("well is flooded! fragment of size", fragment_size, " will have a long smeared band")
					continue
				if gel.well_capacity >gel.well_max_capacity and fragment_size < 8.0:
					gel_band = $GelWellTopViewSmudge2.duplicate()
					well.gel_band_sprites.append(gel_band)
					gel_band.position = substance.position
					base_gel_sprite.visible = true
					base_wells_sprite.visible = true
					print("well is flooded! fragment of size", fragment_size, " will have a long smeared band")
					continue
			print("Inconclusive results.")
			display_blank_gel_bands()

func display_gel_bands() -> void:
	#Conditions for entirely invisible gel bands
	if gel.electrode_correct_placement == false:
		print("electrodes plugged in backwards! gel sprite will be blank")
		display_blank_gel_bands()
	if gel.voltage > 120:
		print("electrodes plugged in backwards! gel sprite will be blank")
		display_blank_gel_bands()
	if gel.voltage_run_time >20:
		print("voltage run too long! gel sprite will be blank")
		display_blank_gel_bands()
	#Well Capacity states
	analyze_gel(gel)
