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
		$AttachmentInteractableArea.remove_object()
	else:
		for body: LabBody in  $AttachmentInteractableArea.get_overlapping_bodies():
			if body.name == "GelMold":
				$AttachmentInteractableArea.contained_object = body
				print("there is something already in the imager")

func display_blank_gel_bands() -> void:
	base_gel_sprite.visible = true
	base_wells_sprite.visible = true
	
func analyze_gel_state(gel: LabBody) -> void:
	for i: int in gel.num_wells():
		var well: ContainerComponent = gel.get_well(i)
		for substance: SubstanceInstance in well.substances:
			for fragment_size: float in substance.dna_sizes:
				if gel.gel_concentration == 0.5 and (fragment_size >= 2.0 and fragment_size <=30.0) and (well.well_capacity >2.5 and well.well_capacity <=5.0) and gel.voltage_run_time == 20.0 and gel.correct_comb_placement == true and gel.correct_gel_mixing == true and gel.correct_gel_temperature == true and gel.gel_analysis_asap == true and gel.voltage == 120:
					print("perfect! Here's a perfect gel band sprite with long ladders for", well["name"], " !")
					#gel_band = appropriate_sprite
					#gel_band.position = substance.position
					
	#match well:
			## Perfect results
			#{
					#"well_capacity":  var well_capacity, 
					#"dna_size": var dna_size, ..
			#} when gel_state.gel_concentration == 0.5 and (dna_size >= 2.0 and dna_size <=30.0) and (well_capacity >2.5 and well_capacity <=5.0) and gel_state.voltage_run_time == 20.0 and gel_state.correct_comb_placement == true and gel_state.correct_gel_mixing == true and gel_state.correct_gel_temperature == true and gel_state.gel_analysis_asap == true and gel_state.voltage == 120:
					#well["gel_state.GelBandState"] = gel_state.GelBandState.PERFECT_LONG
					#base_gel_sprite.visible = true
					#well["gel_band_sprite"] = appropriate_sprite
					#well["gel_band_sprite"].visible = true
					#print("perfect! Here's a perfect gel band sprite with long ladders for", well["name"], " !")
			#{
					#"well_capacity": var well_capacity, 
					#"dna_size": var dna_size, ..
			#} when gel_state.gel_concentration == 0.7 and (dna_size >= 0.8 and dna_size <=12.0) and (well_capacity >2.5 and well_capacity <=5.0) and gel_state.voltage_run_time == 20.0 and gel_state.correct_comb_placement == true and gel_state.correct_gel_mixing == true and gel_state.correct_gel_temperature == true and gel_state.gel_analysis_asap == true and gel_state.voltage == 120:
					#well["gel_state.GelBandState"] = gel_state.GelBandState.PERFECT_LONG
					##base_gel_sprite.visible = true
					##well["gel_band_sprite"] = appropriate_sprite
					##well["gel_band_sprite"].visible = true
					#print("perfect! Here's a perfect gel band sprite with long ladders for", well["name"], "!")
			#{
					#"well_capacity": var well_capacity, 
					#"dna_size": var dna_size, ..
			#} when gel_state.gel_concentration == 1.0 and (dna_size >= 0.4 and dna_size <=8.0) and (well_capacity >2.5 and well_capacity <=5.0) and gel_state.voltage_run_time == 20.0 and gel_state.correct_comb_placement == true and gel_state.correct_gel_mixing == true and gel_state.correct_gel_temperature == true and gel_state.gel_analysis_asap == true and gel_state.voltage == 120:
					#well["gel_state.GelBandState"] = gel_state.GelBandState.PERFECT_LONG
					##base_gel_sprite.visible = true
					##well["gel_band_sprite"] = appropriate_sprite
					##well["gel_band_sprite"].visible = true
					#print("perfect! Here's a perfect gel band sprite with long ladders for", well["name"], "!")
			#{ 
					#"well_capacity": var well_capacity, 
					#"dna_size": var dna_size, ..
			#} when gel_state.gel_concentration == 1.2 and (dna_size >= 0.3 and dna_size <=7.0) and (well_capacity >2.5 and well_capacity <=5.0) and gel_state.voltage_run_time == 20.0 and gel_state.correct_comb_placement == true and gel_state.correct_gel_mixing == true and gel_state.correct_gel_temperature == true and gel_state.gel_analysis_asap == true and gel_state.voltage == 120:
				#well["gel_state.GelBandState"] = gel_state.GelBandState.PERFECT_SHORT
					##base_gel_sprite.visible = true
					##well["gel_band_sprite"] = appropriate_sprite
					##well["gel_band_sprite"].visible = true
				#print("perfect! Here's a perfect gel band sprite with short ladders for", well["name"], "!")
			#{
					#"well_capacity": var well_capacity, 
					#"dna_size": var dna_size, ..
			#} when gel_state.gel_concentration == 1.5 and (dna_size >= 0.2 and dna_size <=3.0) and (well_capacity >2.5 and well_capacity <=5.0) and gel_state.voltage_run_time == 20.0 and gel_state.correct_comb_placement == true and gel_state.correct_gel_mixing == true and gel_state.correct_gel_temperature == true and gel_state.gel_analysis_asap == true and gel_state.voltage == 120:
					#well["gel_state.GelBandState"] = gel_state.GelBandState.PERFECT_SHORT
					##base_gel_sprite.visible = true
					##well["gel_band_sprite"] = appropriate_sprite
					##well["gel_band_sprite"].visible = true
					#print("perfect! Here's a perfect gel band sprite with short ladders for", well["name"], "!")
			#{
					#"well_capacity": var well_capacity, 
					#"dna_size": var dna_size, ..
			#} when gel_state.gel_concentration == 2.0 and (dna_size >= 0.1 and dna_size <=2.0) and (well_capacity >2.5 and well_capacity <=5.0) and gel_state.voltage_run_time == 20.0 and gel_state.correct_comb_placement == true and gel_state.correct_gel_mixing == true and gel_state.correct_gel_temperature == true and gel_state.gel_analysis_asap == true and gel_state.voltage == 120:
					#well["gel_state.GelBandState"] = gel_state.GelBandState.PERFECT_SHORT
					##base_gel_sprite.visible = true
					##well["gel_band_sprite"] = appropriate_sprite
					##well["gel_band_sprite"].visible = true
					#print("perfect! Here's a perfect gel band sprite with short ladders for", well["name"], "!")
			##Conditions for singular well invisible gel bands
			#{"well_capacity": var well_capacity,..} when well_capacity <=2.5:
				#well["gel_state.GelBandState"] = gel_state.GelBandState.BLANK
				##base_gel_sprite.visible = true
				##well["gel_band_sprite"] = appropriate_sprite
				##well["gel_band_sprite"].visible = true
				#print("well capacity not full enough!", well["name"], " gel sprite will be blank")
			## Conditions for fuzzy or diffused gel bands
			#{"dna_size": var dna_size, ..} when gel_state.voltage <120 and dna_size >= 0.1:
				#well["gel_state.GelBandState"] = gel_state.GelBandState.DIFFUSED_LONG
				##base_gel_sprite.visible = true
				##well["gel_band_sprite"] = appropriate_sprite
				##well["gel_band_sprite"].visible = true
				#print("voltage too low!", well["name"], " gel sprite will have fuzzy bands")
			#{"dna_size": var dna_size, ..} when gel_state.gel_concentration <120 and dna_size < 0.1:
				#well["gel_state.GelBandState"] = gel_state.GelBandState.DIFFUSED_SHORT
				##base_gel_sprite.visible = true
				##well["gel_band_sprite"] = appropriate_sprite
				##well["gel_band_sprite"].visible = true
				#print("voltage too low!", well["name"], " gel sprite will have fuzzy bands")
			#{"dna_size": var dna_size, ..} when gel_state.voltage_run_time <20 and dna_size >= 0.1:
				#well["gel_state.GelBandState"] = gel_state.GelBandState.DIFFUSED_LONG
				##base_gel_sprite.visible = true
				##well["gel_band_sprite"] = appropriate_sprite
				##well["gel_band_sprite"].visible = true
				#print("voltage run too short!", well["name"], " gel sprite will have fuzzy bands")
			#{"dna_size": var dna_size, ..} when gel_state.voltage_run_time <20 and dna_size < 0.1:
				#well["gel_state.GelBandState"] = gel_state.GelBandState.DIFFUSED_LONG
				##base_gel_sprite.visible = true
				##well["gel_band_sprite"] = appropriate_sprite
				##well["gel_band_sprite"].visible = true
				#print("voltage run too short!", well["name"], " gel sprite will have fuzzy bands")
			#{"dna_size": var dna_size, ..} when gel_state.gel_concentration < 2.0 and dna_size >= 0.1 and dna_size <=2.0:
				#well["gel_state.GelBandState"] = gel_state.GelBandState.DIFFUSED_SHORT
				##base_gel_sprite.visible = true
				##well["gel_band_sprite"] = appropriate_sprite
				##well["gel_band_sprite"].visible = true
				#print("gel concentration too low for 0.1kb-2kb dna size!", well["name"], " gel sprite will have fuzzy bands")
			#{"dna_size": var dna_size, ..} when gel_state.gel_concentration >2.0 and dna_size >= 0.1 and dna_size <=2.0:
				#well["gel_state.GelBandState"] = gel_state.GelBandState.DIFFUSED_SHORT
				##base_gel_sprite.visible = true
				##well["gel_band_sprite"] = appropriate_sprite
				##well["gel_band_sprite"].visible = true
				#print("gel concentration too high for 0.1kb-2kb dna size!", well["name"], " gel sprite will have fuzzy bands")
			#{"dna_size": var dna_size, ..} when gel_state.gel_concentration < 1.5 and dna_size >= 0.2 and dna_size <=3.0:
				#well["gel_state.GelBandState"] = gel_state.GelBandState.DIFFUSED_SHORT
				##base_gel_sprite.visible = true
				##well["gel_band_sprite"] = appropriate_sprite
				##well["gel_band_sprite"].visible = true
				#print("gel concentration too low for 0.2kb-3kb dna size!", well["name"], " gel sprite will have fuzzy bands")
			#{"dna_size": var dna_size, ..} when gel_state.gel_concentration >1.5 and dna_size >= 0.2 and dna_size <=3.0:
				#well["gel_state.GelBandState"] = gel_state.GelBandState.DIFFUSED_SHORT
				##base_gel_sprite.visible = true
				##well["gel_band_sprite"] = appropriate_sprite
				##well["gel_band_sprite"].visible = true
				#print("gel concentration too high for 0.2kb-3kb dna size!", well["name"], " gel sprite will have fuzzy bands")
			#{"dna_size": var dna_size, ..} when gel_state.gel_concentration < 1.2 and dna_size >= 0.3 and dna_size <=7.0:
				#well["gel_state.GelBandState"] = gel_state.GelBandState.DIFFUSED_SHORT
				##base_gel_sprite.visible = true
				##well["gel_band_sprite"] = appropriate_sprite
				##well["gel_band_sprite"].visible = true
				#print("gel concentration too low for 0.3kb-7kb dna size!", well["name"], " gel sprite will have fuzzy bands")
			#{"dna_size": var dna_size, ..} when gel_state.gel_concentration >1.2 and dna_size >= 0.3 and dna_size <=7.0:
				#well["gel_state.GelBandState"] = gel_state.GelBandState.DIFFUSED_SHORT
				##base_gel_sprite.visible = true
				##well["gel_band_sprite"] = appropriate_sprite
				##well["gel_band_sprite"].visible = true
				#print("gel concentration too high for 0.3kb-7kb dna size!", well["name"], " gel sprite will have fuzzy bands")
			#{"dna_size": var dna_size, ..} when gel_state.gel_concentration < 1.0 and dna_size >= 0.4 and dna_size <=8.0:
				#well["gel_state.GelBandState"] = gel_state.GelBandState.DIFFUSED_LONG
				##base_gel_sprite.visible = true
				##well["gel_band_sprite"] = appropriate_sprite
				##well["gel_band_sprite"].visible = true
				#print("gel concentration too low for 0.4kb-8kb dna size!", well["name"], " gel sprite will have fuzzy bands")
			#{"dna_size": var dna_size, ..} when gel_state.gel_concentration >1.0 and dna_size >= 0.4 and dna_size <=8.0:
				#well["gel_state.GelBandState"] = gel_state.GelBandState.DIFFUSED_LONG
				##base_gel_sprite.visible = true
				##well["gel_band_sprite"] = appropriate_sprite
				##well["gel_band_sprite"].visible = true
				#print("gel concentration too high for 0.4b-8kb dna size!", well["name"], " gel sprite will have fuzzy bands")
			#{"dna_size": var dna_size, ..} when gel_state.gel_concentration < 0.7 and dna_size >= 0.8 and dna_size <=12.0:
				#gel_state.well["gel_state.GelBandState"] = gel_state.GelBandState.DIFFUSED_LONG
				##base_gel_sprite.visible = true
				##well["gel_band_sprite"] = appropriate_sprite
				##well["gel_band_sprite"].visible = true
				#print("gel concentration too low for 0.8kb-12kb dna size!", well["name"], " gel sprite will have fuzzy bands")
			#{"dna_size": var dna_size, ..} when gel_state.gel_concentration >0.7 and dna_size >= 0.8 and dna_size <=12.0:
				#well["gel_state.GelBandState"] = gel_state.GelBandState.DIFFUSED_LONG
				##base_gel_sprite.visible = true
				##well["gel_band_sprite"] = appropriate_sprite
				##well["gel_band_sprite"].visible = true
				#print("gel concentration too high for 0.8kb-12kb dna size!", well["name"], " gel sprite will have fuzzy bands")
			#{"dna_size": var dna_size, ..} when gel_state.gel_concentration < 0.5 and dna_size >= 2.0 and dna_size <=30.0:
				#well["gel_state.GelBandState"] = gel_state.GelBandState.DIFFUSED_LONG
				##base_gel_sprite.visible = true
				##well["gel_band_sprite"] = appropriate_sprite
				##well["gel_band_sprite"].visible = true
				#print("gel concentration too low for 2kb-30kb dna size!",well["name"], " gel sprite will have fuzzy bands")
			#{"dna_size": var dna_size, ..} when gel_state.gel_concentration >0.5 and dna_size >= 2.0 and dna_size <=30.0:
				#well["gel_state.GelBandState"] = gel_state.GelBandState.DIFFUSED_LONG
				##base_gel_sprite.visible = true
				##well["gel_band_sprite"] = appropriate_sprite
				##well["gel_band_sprite"].visible = true
				#print("gel concentration too high for 2kb-30kb dna size!", well["name"], " gel sprite will have fuzzy bands")
			#{"gel_analysis_asap": false,"dna_size": var dna_size, ..} when dna_size >= 8.0:
				#well["gel_state.GelBandState"] = gel_state.GelBandState.DIFFUSED_SHORT
				##base_gel_sprite.visible = true
				##well["gel_band_sprite"] = appropriate_sprite
				##well["gel_band_sprite"].visible = true
				#print("Too much time passed between electorphoresis and gel analysis!", well["name"], " gel sprite will have fuzzy bands")
			#{"gel_analysis_asap": false,"dna_size": var dna_size, ..} when dna_size < 8.0:
				#well["gel_state.GelBandState"] = gel_state.GelBandState.DIFFUSED_SHORT
				##base_gel_sprite.visible = true
				##well["gel_band_sprite"] = appropriate_sprite
				##well["gel_band_sprite"].visible = true
				#print("Too much time passed between electorphoresis and gel analysis!", well["name"], " gel sprite will have fuzzy bands")
			##Conditions for smiley/wavy/smeared bands
			#{"dna_size": var dna_size, ..} when gel_state.correct_gel_temperature == false and dna_size >= 8.0:
				#well["gel_state.GelBandState"] = gel_state.GelBandState.WAVY_LONG
				##base_gel_sprite.visible = true
				##well["gel_band_sprite"] = appropriate_sprite
				##well["gel_band_sprite"].visible = true
				#print("gel heated to incorrect temperature!", well["name"], " gel sprite will have wavy or smeared bands")
			#{"dna_size": var dna_size, ..} when gel_state.correct_gel_temperature == false and dna_size < 8.0:
				#well["gel_state.GelBandState"] = gel_state.GelBandState.WAVY_SHORT
				##base_gel_sprite.visible = true
				##well["gel_band_sprite"] = appropriate_sprite
				##well["gel_band_sprite"].visible = true
				#print("gel heated to incorrect temperature!", well["name"], " gel sprite will have wavy or smeared bands")
			#{"dna_size": var dna_size, ..} when  gel_state.correct_gel_mixing == false and dna_size >= 8.0:
				#well["gel_state.GelBandState"] = gel_state.GelBandState.WAVY_LONG
				##base_gel_sprite.visible = true
				##well["gel_band_sprite"] = appropriate_sprite
				##well["gel_band_sprite"].visible = true
				#print("gel not mixed well before electrophoresis!", well["name"], " gel sprite will have wavy bands")
			#{"dna_size": var dna_size, ..} when gel_state.correct_gel_mixing == false and  dna_size < 8.0:
				#well["gel_state.GelBandState"] = gel_state.GelBandState.WAVY_SHORT
				##base_gel_sprite.visible = true
				##well["gel_band_sprite"] = appropriate_sprite
				##well["gel_band_sprite"].visible = true
				#print("gel not mixed well before electrophoresis!", well["name"], " gel sprite will have wavy bands")
			#{"dna_size": var dna_size, ..} when gel_state.correct_comb_placement == false and dna_size >= 8.0:
				#well["gel_state.GelBandState"] = gel_state.GelBandState.WAVY_LONG
				##base_gel_sprite.visible = true
				##well["gel_band_sprite"] = appropriate_sprite
				##well["gel_band_sprite"].visible = true
				#print("gel comb not placed well correctly!", well["name"], " gel sprite will have wavy bands or dna will remain in well")
			#{"dna_size": var dna_size, ..} when  gel_state.correct_comb_placement == false and  dna_size < 8.0:
				#well["gel_state.GelBandState"] = gel_state.GelBandState.WAVY_SHORT
				##base_gel_sprite.visible = true
				##well["gel_band_sprite"] = appropriate_sprite
				##well["gel_band_sprite"].visible = true
				#print("gel comb not placed well correctly!", well["name"], " gel sprite will have wavy bands or dna will remain in well")
			#{"well_capacity": var well_capacity,"dna_size": var dna_size, ..} when well_capacity >5.0 and dna_size >= 8.0:
				#well["gel_state.GelBandState"] = gel_state.GelBandState.SMEARED_LONG
				##base_gel_sprite.visible = true
				##well["gel_band_sprite"] = appropriate_sprite
				##well["gel_band_sprite"].visible = true
				#print("well is flooded!", well["name"], " gel sprite will have smeared bands")
			#{"well_capacity": var well_capacity,"dna_size": var dna_size, ..} when well_capacity >5.0 and dna_size < 8.0:
				#well["gel_state.GelBandState"] = gel_state.GelBandState.SMEARED_SHORT
				##base_gel_sprite.visible = true
				##well["gel_band_sprite"] = appropriate_sprite
				##well["gel_band_sprite"].visible = true
				#print("well is flooded!", well["name"], " gel sprite will have smeared bands")
			#_:
				#print("Inconclusive results.")
				#display_blank_gel_bands()

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
	analyze_gel_state(gel)
