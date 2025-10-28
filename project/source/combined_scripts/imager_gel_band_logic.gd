extends Imager

var visibleGelSprite: Sprite2D = null

func on_gel_inserted() -> void:
	if get_UV_state() == true:
		print("starting imaging")
		display_gel_bands()
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
		visibleGelSprite.visible = false
		visibleGelSprite = null
		$AttachmentInteractableArea.remove_object()
	else:
		for body: LabBody in  $AttachmentInteractableArea.get_overlapping_bodies():
			if body.name == "GelMold":
				$AttachmentInteractableArea.contained_object = body
				print("there is something already in the imager")

func display_blank_gel_bands() -> void:
	visibleGelSprite = $BlankGelBands
	$BlankGelBands.visible = true
	
func analyze_gel_state(well: Dictionary) -> void:
	
	match well:
			# Perfect results
			{
					"well_capacity":  var well_capacity, 
					"dna_size": var dna_size, ..
			} when gel_state.gel_concentration == 0.5 and (dna_size >= 2.0 and dna_size <=30.0) and (well_capacity >2.5 and well_capacity <=5.0) and gel_state.voltage_run_time == 20.0 and gel_state.correct_comb_placement == true and gel_state.correct_gel_mixing == true and gel_state.correct_gel_temperature == true and gel_state.gel_analysis_asap == true and gel_state.voltage == 120:
					well["gel_state.GelBandState"] = gel_state.GelBandState.PERFECT_LONG
					print("perfect! Here's a perfect gel band sprite with long ladders for", well["name"], " !")
			{
					"well_capacity": var well_capacity, 
					"dna_size": var dna_size, ..
			} when gel_state.gel_concentration == 0.7 and (dna_size >= 0.8 and dna_size <=12.0) and (well_capacity >2.5 and well_capacity <=5.0) and gel_state.voltage_run_time == 20.0 and gel_state.correct_comb_placement == true and gel_state.correct_gel_mixing == true and gel_state.correct_gel_temperature == true and gel_state.gel_analysis_asap == true and gel_state.voltage == 120:
					well["gel_state.GelBandState"] = gel_state.GelBandState.PERFECT_LONG
					print("perfect! Here's a perfect gel band sprite with long ladders for", well["name"], "!")
			{
					"well_capacity": var well_capacity, 
					"dna_size": var dna_size, ..
			} when gel_state.gel_concentration == 1.0 and (dna_size >= 0.4 and dna_size <=8.0) and (well_capacity >2.5 and well_capacity <=5.0) and gel_state.voltage_run_time == 20.0 and gel_state.correct_comb_placement == true and gel_state.correct_gel_mixing == true and gel_state.correct_gel_temperature == true and gel_state.gel_analysis_asap == true and gel_state.voltage == 120:
					well["gel_state.GelBandState"] = gel_state.GelBandState.PERFECT_LONG
					print("perfect! Here's a perfect gel band sprite with long ladders for", well["name"], "!")
			{ 
					"well_capacity": var well_capacity, 
					"dna_size": var dna_size, ..
			} when gel_state.gel_concentration == 1.2 and (dna_size >= 0.3 and dna_size <=7.0) and (well_capacity >2.5 and well_capacity <=5.0) and gel_state.voltage_run_time == 20.0 and gel_state.correct_comb_placement == true and gel_state.correct_gel_mixing == true and gel_state.correct_gel_temperature == true and gel_state.gel_analysis_asap == true and gel_state.voltage == 120:
				well["gel_state.GelBandState"] = gel_state.GelBandState.PERFECT_SHORT
				print("perfect! Here's a perfect gel band sprite with short ladders for", well["name"], "!")
			{
					"well_capacity": var well_capacity, 
					"dna_size": var dna_size, ..
			} when gel_state.gel_concentration == 1.5 and (dna_size >= 0.2 and dna_size <=3.0) and (well_capacity >2.5 and well_capacity <=5.0) and gel_state.voltage_run_time == 20.0 and gel_state.correct_comb_placement == true and gel_state.correct_gel_mixing == true and gel_state.correct_gel_temperature == true and gel_state.gel_analysis_asap == true and gel_state.voltage == 120:
					well["gel_state.GelBandState"] = gel_state.GelBandState.PERFECT_SHORT
					print("perfect! Here's a perfect gel band sprite with short ladders for", well["name"], "!")
			{
					"well_capacity": var well_capacity, 
					"dna_size": var dna_size, ..
			} when gel_state.gel_concentration == 2.0 and (dna_size >= 0.1 and dna_size <=2.0) and (well_capacity >2.5 and well_capacity <=5.0) and gel_state.voltage_run_time == 20.0 and gel_state.correct_comb_placement == true and gel_state.correct_gel_mixing == true and gel_state.correct_gel_temperature == true and gel_state.gel_analysis_asap == true and gel_state.voltage == 120:
					well["gel_state.GelBandState"] = gel_state.GelBandState.PERFECT_SHORT
					print("perfect! Here's a perfect gel band sprite with short ladders for", well["name"], "!")
			#Conditions for singular well invisible gel bands
			{"well_capacity": var well_capacity,..} when well_capacity <=2.5:
				print("well capacity not full enough!", well["name"], " gel sprite will be blank")
				well["gel_state.GelBandState"] = gel_state.GelBandState.BLANK
			# Conditions for fuzzy or diffused gel bands
			{"dna_size": var dna_size, ..} when gel_state.voltage <120 and dna_size >= 0.1:
				print("voltage too low!", well["name"], " gel sprite will have fuzzy bands")
				well["gel_state.GelBandState"] = gel_state.GelBandState.DIFFUSED_LONG
			{"dna_size": var dna_size, ..} when gel_state.gel_concentration <120 and dna_size < 0.1:
				print("voltage too low!", well["name"], " gel sprite will have fuzzy bands")
				well["gel_state.GelBandState"] = gel_state.GelBandState.DIFFUSED_SHORT
			{"dna_size": var dna_size, ..} when gel_state.voltage_run_time <20 and dna_size >= 0.1:
				print("voltage run too short!", well["name"], " gel sprite will have fuzzy bands")
				well["gel_state.GelBandState"] = gel_state.GelBandState.DIFFUSED_LONG
			{"dna_size": var dna_size, ..} when gel_state.voltage_run_time <20 and dna_size < 0.1:
				well["gel_state.GelBandState"] = gel_state.GelBandState.DIFFUSED_LONG
				print("voltage run too short!", well["name"], " gel sprite will have fuzzy bands")
			{"dna_size": var dna_size, ..} when gel_state.gel_concentration < 2.0 and dna_size >= 0.1 and dna_size <=2.0:
				well["gel_state.GelBandState"] = gel_state.GelBandState.DIFFUSED_SHORT
				print("gel concentration too low for 0.1kb-2kb dna size!", well["name"], " gel sprite will have fuzzy bands")
			{"dna_size": var dna_size, ..} when gel_state.gel_concentration >2.0 and dna_size >= 0.1 and dna_size <=2.0:
				well["gel_state.GelBandState"] = gel_state.GelBandState.DIFFUSED_SHORT
				print("gel concentration too high for 0.1kb-2kb dna size!", well["name"], " gel sprite will have fuzzy bands")
			{"dna_size": var dna_size, ..} when gel_state.gel_concentration < 1.5 and dna_size >= 0.2 and dna_size <=3.0:
				well["gel_state.GelBandState"] = gel_state.GelBandState.DIFFUSED_SHORT
				print("gel concentration too low for 0.2kb-3kb dna size!", well["name"], " gel sprite will have fuzzy bands")
			{"dna_size": var dna_size, ..} when gel_state.gel_concentration >1.5 and dna_size >= 0.2 and dna_size <=3.0:
				well["gel_state.GelBandState"] = gel_state.GelBandState.DIFFUSED_SHORT
				print("gel concentration too high for 0.2kb-3kb dna size!", well["name"], " gel sprite will have fuzzy bands")
			{"dna_size": var dna_size, ..} when gel_state.gel_concentration < 1.2 and dna_size >= 0.3 and dna_size <=7.0:
				well["gel_state.GelBandState"] = gel_state.GelBandState.DIFFUSED_SHORT
				print("gel concentration too low for 0.3kb-7kb dna size!", well["name"], " gel sprite will have fuzzy bands")
			{"dna_size": var dna_size, ..} when gel_state.gel_concentration >1.2 and dna_size >= 0.3 and dna_size <=7.0:
				well["gel_state.GelBandState"] = gel_state.GelBandState.DIFFUSED_SHORT
				print("gel concentration too high for 0.3kb-7kb dna size!", well["name"], " gel sprite will have fuzzy bands")
			{"dna_size": var dna_size, ..} when gel_state.gel_concentration < 1.0 and dna_size >= 0.4 and dna_size <=8.0:
				well["gel_state.GelBandState"] = gel_state.GelBandState.DIFFUSED_LONG
				print("gel concentration too low for 0.4kb-8kb dna size!", well["name"], " gel sprite will have fuzzy bands")
			{"dna_size": var dna_size, ..} when gel_state.gel_concentration >1.0 and dna_size >= 0.4 and dna_size <=8.0:
				well["gel_state.GelBandState"] = gel_state.GelBandState.DIFFUSED_LONG
				print("gel concentration too high for 0.4b-8kb dna size!", well["name"], " gel sprite will have fuzzy bands")
			{"dna_size": var dna_size, ..} when gel_state.gel_concentration < 0.7 and dna_size >= 0.8 and dna_size <=12.0:
				gel_state.well["gel_state.GelBandState"] = gel_state.GelBandState.DIFFUSED_LONG
				print("gel concentration too low for 0.8kb-12kb dna size!", well["name"], " gel sprite will have fuzzy bands")
			{"dna_size": var dna_size, ..} when gel_state.gel_concentration >0.7 and dna_size >= 0.8 and dna_size <=12.0:
				well["gel_state.GelBandState"] = gel_state.GelBandState.DIFFUSED_LONG
				print("gel concentration too high for 0.8kb-12kb dna size!", well["name"], " gel sprite will have fuzzy bands")
			{"dna_size": var dna_size, ..} when gel_state.gel_concentration < 0.5 and dna_size >= 2.0 and dna_size <=30.0:
				well["gel_state.GelBandState"] = gel_state.GelBandState.DIFFUSED_LONG
				print("gel concentration too low for 2kb-30kb dna size!",well["name"], " gel sprite will have fuzzy bands")
			{"dna_size": var dna_size, ..} when gel_state.gel_concentration >0.5 and dna_size >= 2.0 and dna_size <=30.0:
				well["gel_state.GelBandState"] = gel_state.GelBandState.DIFFUSED_LONG
				print("gel concentration too high for 2kb-30kb dna size!", well["name"], " gel sprite will have fuzzy bands")
			{"gel_analysis_asap": false,"dna_size": var dna_size, ..} when dna_size >= 8.0:
				well["gel_state.GelBandState"] = gel_state.GelBandState.DIFFUSED_SHORT
				print("Too much time passed between electorphoresis and gel analysis!", well["name"], " gel sprite will have fuzzy bands")
			{"gel_analysis_asap": false,"dna_size": var dna_size, ..} when dna_size < 8.0:
				well["gel_state.GelBandState"] = gel_state.GelBandState.DIFFUSED_SHORT
				print("Too much time passed between electorphoresis and gel analysis!", well["name"], " gel sprite will have fuzzy bands")
			#Conditions for smiley/wavy/smeared bands
			{"dna_size": var dna_size, ..} when gel_state.correct_gel_temperature == false and dna_size >= 8.0:
				well["gel_state.GelBandState"] = gel_state.GelBandState.WAVY_LONG
				print("gel heated to incorrect temperature!", well["name"], " gel sprite will have wavy or smeared bands")
			{"dna_size": var dna_size, ..} when gel_state.correct_gel_temperature == false and dna_size < 8.0:
				well["gel_state.GelBandState"] = gel_state.GelBandState.WAVY_SHORT
				print("gel heated to incorrect temperature!", well["name"], " gel sprite will have wavy or smeared bands")
			{"dna_size": var dna_size, ..} when  gel_state.correct_gel_mixing == false and dna_size >= 8.0:
				well["gel_state.GelBandState"] = gel_state.GelBandState.WAVY_LONG
				print("gel not mixed well before electrophoresis!", well["name"], " gel sprite will have wavy bands")
			{"dna_size": var dna_size, ..} when gel_state.correct_gel_mixing == false and  dna_size < 8.0:
				well["gel_state.GelBandState"] = gel_state.GelBandState.WAVY_SHORT
				print("gel not mixed well before electrophoresis!", well["name"], " gel sprite will have wavy bands")
			{"dna_size": var dna_size, ..} when gel_state.correct_comb_placement == false and dna_size >= 8.0:
				well["gel_state.GelBandState"] = gel_state.GelBandState.WAVY_LONG
				print("gel comb not placed well correctly!", well["name"], " gel sprite will have wavy bands or dna will remain in well")
			{"dna_size": var dna_size, ..} when  gel_state.correct_comb_placement == false and  dna_size < 8.0:
				well["gel_state.GelBandState"] = gel_state.GelBandState.WAVY_SHORT
				print("gel comb not placed well correctly!", well["name"], " gel sprite will have wavy bands or dna will remain in well")
			{"well_capacity": var well_capacity,"dna_size": var dna_size, ..} when well_capacity >5.0 and dna_size >= 8.0:
				well["gel_state.GelBandState"] = gel_state.GelBandState.SMEARED_LONG
				print("well is flooded!", well["name"], " gel sprite will have smeared bands")
			{"well_capacity": var well_capacity,"dna_size": var dna_size, ..} when well_capacity >5.0 and dna_size < 8.0:
				well["gel_state.GelBandState"] = gel_state.GelBandState.SMEARED_SHORT
				print("well is flooded!", well["name"], " gel sprite will have smeared bands")
			_:
				print("Inconclusive results.")
				display_blank_gel_bands()

func display_gel_bands() -> void:
	#Conditions for entirely invisible gel bands
	if gel_state.electrode_correct_placement == false:
		print("electrodes plugged in backwards! gel sprite will be blank")
		display_blank_gel_bands()
	if gel_state.voltage > 120:
		print("electrodes plugged in backwards! gel sprite will be blank")
		display_blank_gel_bands()
	if gel_state.voltage_run_time >20:
		print("voltage run too long! gel sprite will be blank")
		display_blank_gel_bands()
	#Well Capacity states
	analyze_gel_state(gel_state.well1)
	analyze_gel_state(gel_state.well2)
	analyze_gel_state(gel_state.well3)
	analyze_gel_state(gel_state.well4)
	analyze_gel_state(gel_state.well5)
	analyze_gel_state(gel_state.well6)
	
	#print(gel_state.well1)
	#print(gel_state.well2)
	#print(gel_state.well3)
	#print(gel_state.well4)
	#print(gel_state.well5)
	#print(gel_state.well6)
