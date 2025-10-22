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
		{"voltage": var voltage,"dna_size": var dna_size, ..} when voltage <120 and dna_size >= 8.0:
			visibleGelSprite = $DiffusedLongLadders
			$DiffusedLongLadders.visible = true
			print("voltage too low! gel sprite will have fuzzy bands")
		{"voltage": var voltage,"dna_size": var dna_size, ..} when voltage <120 and dna_size < 8.0:
			visibleGelSprite = $DiffusedLongLadders
			$DiffusedShortLadders.visible = true
			print("voltage too low! gel sprite will have fuzzy bands")
		{"voltage_run_time": var voltage_run_time,"dna_size": var dna_size, ..} when voltage_run_time <20 and dna_size >= 8.0:
			visibleGelSprite = $DiffusedLongLadders
			$DiffusedLongLadders.visible = true
			print("voltage run too short! gel sprite will have fuzzy bands")
		{"voltage_run_time": var voltage_run_time,"dna_size": var dna_size, ..} when voltage_run_time <20 and dna_size < 8.0:
			visibleGelSprite = $DiffusedLongLadders
			$DiffusedShortLadders.visible = true
			print("voltage run too short! gel sprite will have fuzzy bands")
		{"gel_concentration": var gel_concentration, "dna_size": var dna_size, ..} when gel_concentration < 0.5 and dna_size >= 2.0 and dna_size <=30.0:
			visibleGelSprite = $DiffusedLongLadders
			$DiffusedLongLadders.visible = true
			print("gel concentration too low for 2kb-30kb dna size! gel sprite will have fuzzy bands")
		{"gel_concentration": var gel_concentration, "dna_size": var dna_size, ..} when gel_concentration >0.5 and dna_size >= 2.0 and dna_size <=30.0:
			visibleGelSprite = $DiffusedLongLadders
			$DiffusedLongLadders.visible = true
			print("gel concentration too high for 2kb-30kb dna size! gel sprite will have fuzzy bands")
		{"gel_concentration": var gel_concentration, "dna_size": var dna_size, ..} when gel_concentration < 0.7 and dna_size >= 0.8 and dna_size <=12.0:
			visibleGelSprite = $DiffusedLongLadders
			$DiffusedLongLadders.visible = true
			print("gel concentration too low for 0.8kb-12kb dna size! gel sprite will have fuzzy bands")
		{"gel_concentration": var gel_concentration, "dna_size": var dna_size, ..} when gel_concentration >0.7 and dna_size >= 0.8 and dna_size <=12.0:
			visibleGelSprite = $DiffusedLongLadders
			$DiffusedLongLadders.visible = true
			print("gel concentration too high for 0.8kb-12kb dna size! gel sprite will have fuzzy bands")
		{"gel_concentration": var gel_concentration, "dna_size": var dna_size, ..} when gel_concentration < 1.0 and dna_size >= 0.4 and dna_size <=8.0:
			visibleGelSprite = $DiffusedLongLadders
			$DiffusedLongLadders.visible = true
			print("gel concentration too low for 0.4kb-8kb dna size! gel sprite will have fuzzy bands")
		{"gel_concentration": var gel_concentration, "dna_size": var dna_size, ..} when gel_concentration >1.0 and dna_size >= 0.4 and dna_size <=8.0:
			visibleGelSprite = $DiffusedLongLadders
			$DiffusedLongLadders.visible = true
			print("gel concentration too high for 0.4b-8kb dna size! gel sprite will have fuzzy bands")
		{"gel_concentration": var gel_concentration, "dna_size": var dna_size, ..} when gel_concentration < 1.2 and dna_size >= 0.3 and dna_size <=7.0:
			visibleGelSprite = $DiffusedShortLadders
			$DiffusedShortLadders.visible = true
			print("gel concentration too low for 0.3kb-7kb dna size! gel sprite will have fuzzy bands")
		{"gel_concentration": var gel_concentration, "dna_size": var dna_size, ..} when gel_concentration >1.2 and dna_size >= 0.3 and dna_size <=7.0:
			visibleGelSprite = $DiffusedShortLadders
			$DiffusedShortLadders.visible = true
			print("gel concentration too high for 0.3kb-7kb dna size! gel sprite will have fuzzy bands")
		{"gel_concentration": var gel_concentration, "dna_size": var dna_size, ..} when gel_concentration < 1.5 and dna_size >= 0.2 and dna_size <=3.0:
			visibleGelSprite = $DiffusedShortLadders
			$DiffusedShortLadders.visible = true
			print("gel concentration too low for 0.2kb-3kb dna size! gel sprite will have fuzzy bands")
		{"gel_concentration": var gel_concentration, "dna_size": var dna_size, ..} when gel_concentration >1.5 and dna_size >= 0.2 and dna_size <=3.0:
			visibleGelSprite = $DiffusedShortLadders
			$DiffusedShortLadders.visible = true
			print("gel concentration too high for 0.2kb-3kb dna size! gel sprite will have fuzzy bands")
		{"gel_concentration": var gel_concentration, "dna_size": var dna_size, ..} when gel_concentration < 2.0 and dna_size >= 0.1 and dna_size <=2.0:
			visibleGelSprite = $DiffusedShortLadders
			$DiffusedShortLadders.visible = true
			print("gel concentration too low for 0.1kb-2kb dna size! gel sprite will have fuzzy bands")
		{"gel_concentration": var gel_concentration, "dna_size": var dna_size, ..} when gel_concentration >2.0 and dna_size >= 0.1 and dna_size <=2.0:
			visibleGelSprite = $DiffusedShortLadders
			$DiffusedShortLadders.visible = true
			print("gel concentration too high for 0.1kb-2kb dna size! gel sprite will have fuzzy bands")
		{"gel_analysis_asap": false,"dna_size": var dna_size, ..} when dna_size >= 8.0:
			visibleGelSprite = $DiffusedShortLadders
			$DiffusedLongLadders.visible = true
			print("Too much time passed between electorphoresis and gel analysis! gel sprite will have fuzzy bands")
		{"gel_analysis_asap": false,"dna_size": var dna_size, ..} when dna_size < 8.0:
			visibleGelSprite = $DiffusedShortLadders
			$DiffusedShortLadders.visible = true
			print("Too much time passed between electorphoresis and gel analysis! gel sprite will have fuzzy bands")
		#Conditions for smiley/wavy/smeared bands
		{"correct_gel_temperature": false,"dna_size": var dna_size, ..} when dna_size >= 8.0:
			visibleGelSprite = $WavyLongLadders
			$WavyLongLadders.visible = true
			print("gel heated to incorrect temperature! gel sprite will have wavy or smeared bands")
		{"correct_gel_temperature": false,"dna_size": var dna_size, ..} when dna_size < 8.0:
			visibleGelSprite = $WavyShortLadders
			$WavyShortLadders.visible = true
			print("gel heated to incorrect temperature! gel sprite will have wavy or smeared bands")
		{"correct_gel_mixing": false,"dna_size": var dna_size, ..} when dna_size >= 8.0:
			visibleGelSprite = $WavyLongLadders
			$WavyLongLadders.visible = true
			print("gel not mixed well before electrophoresis! gel sprite will have wavy bands")
		{"correct_gel_mixing": false,"dna_size": var dna_size, ..} when dna_size < 8.0:
			visibleGelSprite = $WavyShortLadders
			$WavyShortLadders.visible = true
			print("gel not mixed well before electrophoresis! gel sprite will have wavy bands")
		{"correct_comb_placement": false,"dna_size": var dna_size, ..} when dna_size >= 8.0:
			visibleGelSprite = $WavyLongLadders
			$WavyLongLadders.visible = true
			print("gel comb not placed well correctly! gel sprite will have wavy bands or dna will remain in wells")
		{"correct_comb_placement": false,"dna_size": var dna_size, ..} when dna_size < 8.0:
			visibleGelSprite = $WavyShortLadders
			$WavyShortLadders.visible = true
			print("gel comb not placed well correctly! gel sprite will have wavy bands or dna will remain in wells")
		{"well_capacity": var well_capacity,"dna_size": var dna_size, ..} when well_capacity >5.0 and dna_size >= 8.0:
			visibleGelSprite = $SmearedLongLadders
			$SmearedLongLadders.visible = true
			print("well is flooded! gel sprite will have smeared bands")
		{"well_capacity": var well_capacity,"dna_size": var dna_size, ..} when well_capacity >5.0 and dna_size < 8.0:
			visibleGelSprite = $SmearedShortLadders 
			$SmearedShortLadders.visible = true
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
		} when gel_concentration == 0.5 and (dna_size >= 2.0 and dna_size <=30.0) and (well_capacity >2.5 and well_capacity <=5.0):
				visibleGelSprite = $PerfectLongLadders
				$PerfectLongLadders.visible = true
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
		} when gel_concentration == 0.7 and (dna_size >= 0.8 and dna_size <=12.0) and (well_capacity >2.5 and well_capacity <=5.0):
				visibleGelSprite = $PerfectLongLadders
				$PerfectLongLadders.visible = true
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
		} when gel_concentration == 1.0 and (dna_size >= 0.4 and dna_size <=8.0) and (well_capacity >2.5 and well_capacity <=5.0):
				visibleGelSprite = $PerfectLongLadders
				$PerfectLongLadders.visible = true
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
		} when gel_concentration == 1.2 and (dna_size >= 0.3 and dna_size <=7.0) and (well_capacity >2.5 and well_capacity <=5.0):
				visibleGelSprite = $PerfectShortLadders
				$PerfectShortLadders.visible = true
				("perfect! Here's a perfect gel band sprite with short ladders!")
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
		} when gel_concentration == 1.5 and (dna_size >= 0.2 and dna_size <=3.0) and (well_capacity >2.5 and well_capacity <=5.0):
				visibleGelSprite = $PerfectShortLadders
				$PerfectShortLadders.visible = true
				print("perfect! Here's a perfect gel band sprite with short ladders!")
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
		} when gel_concentration == 2.0 and (dna_size >= 0.1 and dna_size <=2.0) and (well_capacity >2.5 and well_capacity <=5.0):
				visibleGelSprite = $PerfectShortLadders
				$PerfectShortLadders.visible = true
				print("perfect! Here's a perfect gel band sprite with short ladders!")
		_:
			print("Inconclusive results.")
			print("Current Gel state:", gel_state)
			display_blank_gel_bands()
