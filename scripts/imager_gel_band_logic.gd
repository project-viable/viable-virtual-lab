extends Imager

var band_texture: Texture2D = preload("res://textures/gel_bands/Gel_Well_Top_View_PERFECT.svg")
var _is_light_on := false
var results_message: String = ""

func _draw() -> void:
	if $AttachmentInteractableArea.contained_object is GelMold:
		var gel := $AttachmentInteractableArea.contained_object as GelMold
		if not gel or not _is_light_on: return
		gel.set_gel_state()
		if gel.gel_state.correct_comb_placement == false:
			if Engine.get_physics_frames() % 60 == 0:
					results_message = str("Comb placement was incorrect. Gel sprite will be blank")
		else:
			for i:int in gel.num_wells():
				var well_sprite := _get_well_sprite(i + 1)
				var well: ContainerComponent = gel.get_well(i + 1)
				if not well or not well_sprite: continue
				well_sprite.show()
				for s in well.substances:
					if s is DNASolutionSubstance:
						# 130 / 0.45 is about the distance in local sprite coordinates to the end of the
						analyze_gel_state(gel, well, i)
						var pos: Vector2 = Vector2.DOWN * s.position * 130.0 / 0.45
						band_texture.draw(well_sprite.get_canvas_item(), pos)
	else:
		$AttachmentInteractableArea.remove_object()
		$AttachmentInteractableArea.contained_object = null


func _process(_delta: float) -> void:
	for i in 5:
		var well_sprite := _get_well_sprite(i + 1)
		if well_sprite: well_sprite.queue_redraw()

	queue_redraw()
	Game.debug_overlay.update("results", results_message)

func _get_well_sprite(i: int) -> Node2D:
	return get_node_or_null("%%Well%s" % [i])
	
func on_gel_removed() -> void:
	if $AttachmentInteractableArea.contained_object != null:
		$AttachmentInteractableArea.contained_object.global_position = Vector2(1650, 350)
		$AttachmentInteractableArea.remove_object()
		$AttachmentInteractableArea.contained_object = null
	
		

func _on_uv_light_pressed() -> void:
	_is_light_on = not _is_light_on
	
func analyze_gel_state(gel: GelMold, well: ContainerComponent, i: int) -> void:
	for substance: Substance in well.substances:
		if substance is DNASolutionSubstance:
			var fragment: float = substance.fragment_size /1000.0
			#Conditions for singular well invisible gel bands
			if gel.gel_state.well_capacities[i] <= (gel.gel_state.well_max_capacity/2.0):
				if Engine.get_physics_frames() % 60 == 0:
					results_message = str("well %s capacity not full enough gel sprite will be blank" % [i+1])
				continue
			
			#Perfect results
			elif (gel.gel_state.gel_concentration >= 0.5 and  gel.gel_state.gel_concentration < 0.6)  and (fragment >= 2.0 and fragment <=30.0) and (gel.gel_state.well_capacities[i] >=gel.gel_state.well_max_capacity/2.0 and gel.gel_state.well_capacities[i] <= gel.gel_state.well_max_capacity) and (((gel.gel_state.voltage_run_time/60.0) >= 20.0) and ((gel.gel_state.voltage_run_time/60.0) <21.0)) and gel.gel_state.correct_comb_placement == true and gel.correct_gel_mixing == true and gel.correct_gel_temperature == true and gel.gel_state.gel_analysis_asap == true and gel.gel_state.voltage == 120:
				band_texture = load("res://textures/gel_bands/Gel_Well_Top_View_PERFECT_9slice.svg")
				if Engine.get_physics_frames() % 60 == 0:
					results_message = str("perfect! Here's a perfect gel band sprite with long ladders for well ", i, ", fragment size , ",fragment, " !")
				continue
			elif (gel.gel_state.gel_concentration >= 0.7 and  gel.gel_state.gel_concentration < 0.8) and (fragment >= 0.8 and fragment <=12.0) and (gel.gel_state.well_capacities[i] >=gel.gel_state.well_max_capacity/2.0 and gel.gel_state.well_capacities[i] <=gel.gel_state.well_max_capacity) and (((gel.gel_state.voltage_run_time/60.0) >= 20.0) and ((gel.gel_state.voltage_run_time/60.0) <21.0)) and gel.gel_state.correct_comb_placement == true and gel.gel_state.correct_gel_mixing == true and gel.gel_state.correct_gel_temperature == true and gel.gel_state.gel_analysis_asap == true and gel.gel_state.voltage == 120:
					band_texture = load("res://textures/gel_bands/Gel_Well_Top_View_PERFECT_9slice.svg")
					if Engine.get_physics_frames() % 60 == 0:
						results_message = str("perfect! Here's a perfect gel band sprite with long ladders for well ", i, ", fragment size , ",fragment, " !")
					continue
			elif (gel.gel_state.gel_concentration >= 0.1 and  gel.gel_state.gel_concentration < 0.2) and (fragment >= 0.4 and fragment <=8.0) and (gel.gel_state.well_capacities[i] >=gel.gel_state.well_max_capacity/2.0 and gel.gel_state.well_capacities[i] <=gel.gel_state.well_max_capacity) and (((gel.gel_state.voltage_run_time/60.0) >= 20.0) and ((gel.gel_state.voltage_run_time/60.0) <21.0)) and gel.gel_state.correct_comb_placement == true and gel.gel_state.correct_gel_mixing == true and gel.gel_state.correct_gel_temperature == true and gel.gel_state.gel_analysis_asap == true and gel.gel_state.voltage == 120:
				band_texture = load("res://textures/gel_bands/Gel_Well_Top_View_PERFECT_9slice.svg")
				if Engine.get_physics_frames() % 60 == 0:
					results_message = str("perfect! Here's a perfect gel band sprite with long ladders for well ", i, ", fragment size , ",fragment, " !")
				continue
			elif (gel.gel_state.gel_concentration >= 1.2 and  gel.gel_state.gel_concentration < 1.3) and (fragment >= 0.3 and fragment <=7.0) and (gel.gel_state.well_capacities[i] >=gel.gel_state.well_max_capacity/2.0 and gel.gel_state.well_capacities[i] <=gel.gel_state.well_max_capacity) and (((gel.gel_state.voltage_run_time/60.0) >= 20.0) and ((gel.gel_state.voltage_run_time/60.0) <21.0)) and gel.gel_state.correct_comb_placement == true and gel.gel_state.correct_gel_mixing == true and gel.gel_state.correct_gel_temperature == true and gel.gel_state.gel_analysis_asap == true and gel.gel_state.voltage == 120:
				band_texture = load("res://textures/gel_bands/Gel_Well_Top_View_PERFECT_9slice.svg")
				if Engine.get_physics_frames() % 60 == 0:
					results_message = str("perfect! Here's a perfect gel band sprite with short ladders for well ", i, ", fragment size , ",fragment, " !")
				continue
			elif (gel.gel_state.gel_concentration >= 1.5 and  gel.gel_state.gel_concentration < 1.6) and (fragment >= 0.2 and fragment <=3.0) and (gel.gel_state.well_capacities[i] >=gel.gel_state.well_max_capacity/2.0 and gel.gel_state.well_capacities[i] <=gel.gel_state.well_max_capacity) and (((gel.gel_state.voltage_run_time/60.0) >= 20.0) and ((gel.gel_state.voltage_run_time/60.0) <21.0)) and gel.gel_state.correct_comb_placement == true and gel.gel_state.correct_gel_mixing == true and gel.gel_state.correct_gel_temperature == true and gel.gel_state.gel_analysis_asap == true and gel.gel_state.voltage == 120:
				band_texture = load("res://textures/gel_bands/Gel_Well_Top_View_PERFECT.svg")
				if Engine.get_physics_frames() % 60 == 0:
					results_message = str("perfect! Here's a perfect gel band sprite with short ladders for well ", i, ", fragment size , ",fragment, " !")
				continue
			elif (gel.gel_state.gel_concentration >= 2.0 and  gel.gel_state.gel_concentration < 2.1) and (fragment >= 0.1 and fragment <=2.0) and (gel.gel_state.well_capacities[i] >=gel.gel_state.well_max_capacity/2.0 and gel.gel_state.well_capacities[i] <=gel.gel_state.well_max_capacity) and (((gel.gel_state.voltage_run_time/60.0) >= 20.0) and ((gel.gel_state.voltage_run_time/60.0) <21.0)) and gel.gel_state.correct_comb_placement == true and gel.gel_state.correct_gel_mixing == true and gel.gel_state.correct_gel_temperature == true and gel.gel_state.gel_analysis_asap == true and gel.gel_state.voltage == 120:
				band_texture = load("res://textures/gel_bands/Gel_Well_Top_View_PERFECT.svg")
				if Engine.get_physics_frames() % 60 == 0:
					results_message = str("perfect! Here's a perfect gel band sprite with short ladders for well ", i, ", fragment size , ",fragment, " !")
				continue
			# Conditions for fuzzy or diffused gel bands
			elif gel.gel_state.voltage <120 and fragment >= 0.1:
				band_texture = load("res://textures/gel_bands/Gel_Well_Top_View_DIFFUSED_9slice.svg")
				if Engine.get_physics_frames() % 60 == 0:
					results_message = str("voltage too low! fragment of size ", fragment, " will have a long fuzzy band")
				continue
			elif gel.gel_state.voltage <120 and fragment < 0.1:
				band_texture = load("res://textures/gel_bands/Gel_Well_Top_View_DIFFUSED.svg")
				if Engine.get_physics_frames() % 60 == 0:
					results_message = str("voltage too low! fragment of size ", fragment, " will have a short fuzzy band")
				continue
			elif ((gel.gel_state.voltage_run_time/60.0) >= 20.0) and ((gel.gel_state.voltage_run_time/60.0) <21.0) and fragment >= 0.1:
				band_texture = load("res://textures/gel_bands/Gel_Well_Top_View_DIFFUSED_9slice.svg")
				if Engine.get_physics_frames() % 60 == 0:
					results_message = str("voltage not run long enough! fragment of size ", fragment, " will have a long fuzzy band")
				continue
			elif ((gel.gel_state.voltage_run_time/60.0) >= 20.0) and ((gel.gel_state.voltage_run_time/60.0) <21.0) and fragment < 0.1:
				band_texture = load("res://textures/gel_bands/Gel_Well_Top_View_DIFFUSED_9slice.svg")
				if Engine.get_physics_frames() % 60 == 0:
					results_message = str("voltage not run long enough! fragment of size ", fragment, " will have a long fuzzy band")
				continue
			elif gel.gel_state.gel_concentration <= 2.0 and fragment >= 0.1 and fragment <=2.0:
				band_texture = load("res://textures/gel_bands/Gel_Well_Top_View_DIFFUSED.svg")
				if Engine.get_physics_frames() % 60 == 0:
					results_message = str("gel concentration too low for 0.1kb-2kb dna size ! fragment of size ", fragment, " will have a short fuzzy band")
				continue
			elif gel.gel_state.gel_concentration >2.0 and fragment >= 0.1 and fragment <=2.0:
				band_texture = load("res://textures/gel_bands/Gel_Well_Top_View_DIFFUSED.svg")
				if Engine.get_physics_frames() % 60 == 0:
					results_message = str("gel concentration too high for 0.1kb-2kb dna size ! fragment of size ", fragment, " will have a short fuzzy band")
				continue
			elif gel.gel_state.gel_concentration <= 1.5 and fragment >= 0.2 and fragment <=3.0:
				band_texture = load("res://textures/gel_bands/Gel_Well_Top_View_DIFFUSED.svg")
				if Engine.get_physics_frames() % 60 == 0:
					results_message = str("gel concentration too low for 0.2kb-3kb dna size ! fragment of size ", fragment, " will have a short fuzzy band")
				continue
			elif gel.gel_state.gel_concentration >1.5 and fragment >= 0.2 and fragment <=3.0:
				band_texture = load("res://textures/gel_bands/Gel_Well_Top_View_DIFFUSED.svg")
				if Engine.get_physics_frames() % 60 == 0:
					results_message = str("gel concentration too high for 0.2kb-3kb dna size ! fragment of size ", fragment, " will have a short fuzzy band")
				continue
			elif gel.gel_state.gel_concentration <= 1.2 and fragment >= 0.3 and fragment <=7.0:
				band_texture = load("res://textures/gel_bands/Gel_Well_Top_View_DIFFUSED.svg")
				if Engine.get_physics_frames() % 60 == 0:
					results_message = str("gel concentration too low for 0.3kb-7kb dna size ! fragment of size ", fragment, " will have a short fuzzy band")
				continue
			elif gel.gel_state.gel_concentration >1.2 and fragment >= 0.3 and fragment <=7.0:
				band_texture = load("res://textures/gel_bands/Gel_Well_Top_View_DIFFUSED.svg")
				if Engine.get_physics_frames() % 60 == 0:
					results_message = str("gel concentration too high for 0.3kb-7kb dna size ! fragment of size ", fragment, " will have a short fuzzy band")
				continue
			elif gel.gel_state.gel_concentration <= 1.0 and fragment >= 0.4 and fragment <=8.0:
				band_texture = load("res://textures/gel_bands/Gel_Well_Top_View_DIFFUSED_9slice.svg")
				if Engine.get_physics_frames() % 60 == 0:
					results_message = str("gel concentration too low for 0.4kb-8kb dna size ! fragment of size ", fragment, " will have a long fuzzy band")
				continue
			elif gel.gel_state.gel_concentration >1.0 and fragment >= 0.4 and fragment <=8.0:
				band_texture = load("res://textures/gel_bands/Gel_Well_Top_View_DIFFUSED_9slice.svg")
				if Engine.get_physics_frames() % 60 == 0:
					results_message = str("gel concentration too high for 0.4kb-8kb dna size ! fragment of size ", fragment, " will have a long fuzzy band")
				continue
			elif gel.gel_state.gel_concentration <= 0.7 and fragment >= 0.8 and fragment <=12.0:
				band_texture = load("res://textures/gel_bands/Gel_Well_Top_View_DIFFUSED_9slice.svg")
				if Engine.get_physics_frames() % 60 == 0:
					results_message = str("gel concentration too low for 0.8kb-12kb dna size ! fragment of size ", fragment, " will have a long fuzzy band")
				continue
			elif gel.gel_state.gel_concentration >0.7 and fragment >= 0.8 and fragment <=12.0:
				band_texture = load("res://textures/gel_bands/Gel_Well_Top_View_DIFFUSED_9slice.svg")
				if Engine.get_physics_frames() % 60 == 0:
					results_message = str("gel concentration too high for 0.8kb-12kb dna size ! fragment of size ", fragment, " will have a long fuzzy band")
				continue
			elif gel.gel_state.gel_concentration <= 0.5 and fragment >= 2.0 and fragment <=30.0:
				band_texture = load("res://textures/gel_bands/Gel_Well_Top_View_DIFFUSED_9slice.svg")
				if Engine.get_physics_frames() % 60 == 0:
					results_message = str("gel concentration too low for 2kb-30kb dna size ! fragment of size ", fragment, " will have a long fuzzy band")
				continue
			elif gel.gel_state.gel_concentration >0.5 and fragment >= 2.0 and fragment <=30.0:
				band_texture = load("res://textures/gel_bands/Gel_Well_Top_View_DIFFUSED_9slice.svg")
				if Engine.get_physics_frames() % 60 == 0:
					results_message = str("gel concentration too high for 2kb-30kb dna size ! fragment of size ", fragment, " will have a long fuzzy band")
				continue
			elif gel.gel_state.gel_analysis_asap == false and fragment >= 8.0:
				band_texture = load("res://textures/gel_bands/Gel_Well_Top_View_DIFFUSED.svg")
				if Engine.get_physics_frames() % 60 == 0:
					results_message = str("Too much time passed between electorphoresis and gel analysis! fragment of size ", fragment, " will have a short fuzzy band")
				continue
			elif gel.gel_state.gel_analysis_asap == false and fragment < 8.0:
				band_texture = load("res://textures/gel_bands/Gel_Well_Top_View_DIFFUSED.svg")
				if Engine.get_physics_frames() % 60 == 0:
					results_message = str("Too much time passed between electorphoresis and gel analysis! fragment of size ", fragment, " will have a short fuzzy band")
				continue
			#Conditions for smiley/wavy/smeared bands
			elif gel.gel_state.correct_gel_temperature == false and fragment >= 8.0:
				band_texture = load("res://textures/gel_bands/Gel_Well_Top_View_WAVY.svg")
				if Engine.get_physics_frames() % 60 == 0:
					results_message = str("gel heated to incorrect temperature! fragment of size ", fragment, " will have a long wavy band")
				continue
			elif gel.gel_state.correct_gel_temperature == false and fragment < 8.0:
				band_texture = load("res://textures/gel_bands/Gel_Well_Top_View_WAVY_2.svg")
				if Engine.get_physics_frames() % 60 == 0:
					results_message = str("gel heated to incorrect temperature! fragment of size ", fragment, " will have a short wavy band")
				continue
			elif gel.gel_state.correct_comb_placement == false and fragment >= 8.0:
				band_texture = load("res://textures/gel_bands/Gel_Well_Top_View_WAVY.svg")
				if Engine.get_physics_frames() % 60 == 0:
					results_message = str("gel comb not placed well correctly! fragment of size ", fragment, " will have a long wavy band")
				continue
			elif gel.gel_state.correct_comb_placement == false and fragment < 8.0:
				band_texture = load("res://textures/gel_bands/Gel_Well_Top_View_WAVY_2.svg")
				if Engine.get_physics_frames() % 60 == 0:
					results_message = str("gel comb not placed well correctly! fragment of size ", fragment, " will have a short wavy band")
				continue
			elif gel.gel_state.well_capacities[i] >gel.gel_state.well_max_capacity and fragment >= 8.0:
				band_texture = load("res://textures/gel_bands/Gel_Well_Top_View_SMUDGE.svg")
				if Engine.get_physics_frames() % 60 == 0:
					results_message = str("well is flooded! fragment of size ", fragment, " will have a long smeared band")
				continue
			elif gel.gel_state.well_capacities[i] >gel.gel_state.well_max_capacity and fragment < 8.0:
				band_texture = load("res://textures/gel_bands/Gel_Well_Top_View_SMUDGE_2.svg")
				if Engine.get_physics_frames() % 60 == 0:
					results_message = str("well is flooded! fragment of size ", fragment, " will have a long smeared band")
				continue
			else:
				band_texture = load("res://textures/gel_bands/Gel_Well_Top_View_PERFECT.svg")
				if Engine.get_physics_frames() % 60 == 0:
					results_message = str("Inconclusive results.")
				
