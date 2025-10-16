extends Imager

func on_gel_inserted(UV_state: bool) -> void:
	if get_UV_state() == true:
		print("starting imaging")
		display_gel_bands()
	else:
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
		$AttachmentInteractableArea.remove_object()
	else:
		for body: LabBody in  $AttachmentInteractableArea.get_overlapping_bodies():
			if body.name == "GelMold":
				$AttachmentInteractableArea.contained_object = body
				print("there is something already in the imager")

func display_gel_bands() -> void:
	match get_gel_state():
		# Conditions for invisible gel bands
		{"electrode_correct_placement": false,..}:
			print("electrodes plugged in backwards! gel sprite will be blank")
			display_blank_gel_bands()
		{"voltage": var voltage,..} when voltage >120:
			print("voltage too high! gel sprite will be blank")
			display_blank_gel_bands()
		{"voltage_run_time": var voltage_run_time,..} when voltage_run_time >20:
			print("voltage run too long! gel sprite will be blank")
			display_blank_gel_bands()
		{"well_capacity": var well_capacity,..} when well_capacity <=2.5:
			print("well capacity not full enough! gel sprite will be blank")
			display_blank_gel_bands()
		# Conditions for fuzzy or diffused gel bands
		{"voltage": var voltage,..} when voltage <120:
			print("voltage too low! gel sprite will have fuzzy bands")
		{"voltage_run_time": var voltage_run_time,..} when voltage_run_time <20:
			print("voltage run too short! gel sprite will have fuzzy bands")
		{"gel_concentration": var gel_concentration, "dna_size": var dna_size, ..} when gel_concentration < 0.8 and dna_size >25.0:
			print("gel concentration too low for larger dna size! gel sprite will have fuzzy bands")
		{"gel_concentration": var gel_concentration, "dna_size": var dna_size, ..} when gel_concentration > 1.0 and dna_size >25.0:
			print("gel concentration too high for larger dna size! gel sprite will have fuzzy bands")
		{"gel_concentration": var gel_concentration, "dna_size": var dna_size, ..} when gel_concentration < 1.0 and dna_size <=25:
			print("gel concentration too low for smaller dna size! gel sprite will have fuzzy bands")
		{"gel_concentration": var gel_concentration, "dna_size": var dna_size, ..} when gel_concentration >3.0 and dna_size <=25:
			print("gel concentration too high for smaller dna size! gel sprite will have fuzzy bands")
		{"gel_analysis_asap": false,..}:
			print("Too much time passed between electorphoresis and gel analysis! gel sprite will have fuzzy bands")
		#Conditions for smiley/wavy/smeared bands
		{"correct_gel_temperature": false,..}:
			print("gel heated to incorrect temperature! gel sprite will have wavy or smeared bands")
		{"correct_gel_mixing": false,..}:
			print("gel not mixed well before electrophoresis! gel sprite will have wavy bands")
		{"correct_comb_placement": false,..}:
			print("gel comb not placed well correctly! gel sprite will have wavy bands or dna will remain in wells")
		{"well_capacity": var well_capacity,..} when well_capacity >5.0:
			print("well is flooded! gel sprite will have smeared bands")
		# Perfect results
		{
				"electrode_correct_placement": true, 
				"voltage": 120, 
				"gel_concentration": var gel_concentration, 
				"well_capacity":  var well_capacity, 
				"gel_analysis_asap": true, 
				"correct_gel_temperature": true, 
				"correct_comb_placement": true, 
				"correct_gel_mixing": true, 
				"dna_size": var dna_size, 
				"voltage_run_time": 20.0, 
		} when (gel_concentration >= 0.8 and gel_concentration <1.0) and dna_size >25.0 and (well_capacity >2.5 and well_capacity <=5.0):
				print("perfect! Here's a perfect gel band sprite with long ladders!")
		{
				"electrode_correct_placement": true, 
				"voltage": 120, 
				"gel_concentration": var gel_concentration, 
				"well_capacity": var well_capacity, 
				"gel_analysis_asap": true, 
				"correct_gel_temperature": true, 
				"correct_comb_placement": true, 
				"correct_gel_mixing": true, 
				"dna_size": var dna_size, 
				"voltage_run_time": 20.0, 
		} when (gel_concentration >= 1.0 and gel_concentration <=3.0) and dna_size <=25 and (well_capacity >2.5 and well_capacity <=5.0):
				print("perfect! Here's a perfect gel band sprite with short ladders!")
		_:
			print("Inconclusive results. current Gel state:")
			print(gel_state)
			display_blank_gel_bands()
