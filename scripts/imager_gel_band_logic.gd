extends Imager

var band_texture: Texture2D = preload("res://textures/gel_bands/Gel_Well_Top_View_PERFECT.svg")
var _is_light_on := false

func _draw() -> void:
	if $AttachmentInteractableArea.contained_object is GelMold:
		var gel := $AttachmentInteractableArea.contained_object as GelMold
		if not gel or not _is_light_on: return
		for i:int in gel.num_wells():
			var well_sprite := _get_well_sprite(i + 1)
			var well: ContainerComponent = gel.get_well(i + 1)
			if not well or not well_sprite: continue
			well_sprite.show()
			for s in well.substances:
				if s is DNASolutionSubstance:
					# 130 / 0.45 is about the distance in local sprite coordinates to the end of the
					# gel.
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

func _get_well_sprite(i: int) -> Node2D:
	return get_node_or_null("%%Well%s" % [i])
	
func on_gel_removed() -> void:
	if $AttachmentInteractableArea.contained_object != null:
		$AttachmentInteractableArea.contained_object.global_position = Vector2(1650, 350)
		$AttachmentInteractableArea.remove_object()
		$AttachmentInteractableArea.contained_object = null
	
		

func _on_uv_light_pressed() -> void:
	_is_light_on = not _is_light_on
	
#func analyze_gel(gel: LabBody) -> void:
#	for i: int in gel.num_wells():
#		var well: ContainerComponent = gel.get_well(i)
#		for substance: Substance in well.substances:
#			if substance.get_class() == "DNASubstance":
#				for fragment_size: float in substance.fragment_sizes:
#					#Perfect results
#					if gel.gel_concentration == 0.5 and (fragment_size >= 2.0 and fragment_size <=30.0) and (gel.well_capacity >gel.well_max_capacity/2.0 and gel.well_capacity <=gel.well_max_capacity) and gel.voltage_run_time == 20.0 and gel.correct_comb_placement == true and gel.correct_gel_mixing == true and gel.correct_gel_temperature == true and gel.gel_analysis_asap == true and gel.voltage == 120:
#						band_texture = load("res://textures/gel_bands/Gel_Well_Top_View_PERFECT_9slice.svg")
#						base_gel_sprite.visible = true
#						base_wells_sprite.visible = true
#						print("perfect! Here's a perfect gel band sprite with long ladders for well ", i, ", fragment size, ",fragment_size, " !")
#						continue
#					if gel.gel_concentration == 0.7 and (fragment_size >= 0.8 and fragment_size <=12.0) and (gel.well_capacity >gel.well_max_capacity/2.0 and gel.well_capacity <=gel.well_max_capacity) and gel.voltage_run_time == 20.0 and gel.correct_comb_placement == true and gel.correct_gel_mixing == true and gel.correct_gel_temperature == true and gel.gel_analysis_asap == true and gel.voltage == 120:
#						band_texture = load("res://textures/gel_bands/Gel_Well_Top_View_PERFECT_9slice.svg")
#						base_gel_sprite.visible = true
#						base_wells_sprite.visible = true
#						print("perfect! Here's a perfect gel band sprite with long ladders for well ", i, ", fragment size, ",fragment_size, " !")
#						continue
#					if gel.gel_concentration == 1.0 and (fragment_size >= 0.4 and fragment_size <=8.0) and (gel.well_capacity >gel.well_max_capacity/2.0 and gel.well_capacity <=gel.well_max_capacity) and gel.voltage_run_time == 20.0 and gel.correct_comb_placement == true and gel.correct_gel_mixing == true and gel.correct_gel_temperature == true and gel.gel_analysis_asap == true and gel.voltage == 120:
#						band_texture = load("res://textures/gel_bands/Gel_Well_Top_View_PERFECT_9slice.svg")
#						base_gel_sprite.visible = true
#						base_wells_sprite.visible = true
#						print("perfect! Here's a perfect gel band sprite with long ladders for well ", i, ", fragment size, ",fragment_size, " !")
#						continue
#					if gel.gel_concentration == 1.2 and (fragment_size >= 0.3 and fragment_size <=7.0) and (gel.well_capacity >gel.well_max_capacity/2.0 and gel.well_capacity <=gel.well_max_capacity) and gel.voltage_run_time == 20.0 and gel.correct_comb_placement == true and gel.correct_gel_mixing == true and gel.correct_gel_temperature == true and gel.gel_analysis_asap == true and gel.voltage == 120:
#						band_texture = load("res://textures/gel_bands/Gel_Well_Top_View_PERFECT_9slice.svg")
#						base_gel_sprite.visible = true
#						base_wells_sprite.visible = true
#						print("perfect! Here's a perfect gel band sprite with short ladders for well ", i, ", fragment size, ",fragment_size, " !")
#						continue
#					if gel.gel_concentration == 1.5 and (fragment_size >= 0.2 and fragment_size <=3.0) and (gel.well_capacity >gel.well_max_capacity/2.0 and gel.well_capacity <=gel.well_max_capacity) and gel.voltage_run_time == 20.0 and gel.correct_comb_placement == true and gel.correct_gel_mixing == true and gel.correct_gel_temperature == true and gel.gel_analysis_asap == true and gel.voltage == 120:
#						band_texture = load("res://textures/gel_bands/Gel_Well_Top_View_PERFECT.svg")
#						base_gel_sprite.visible = true
#						base_wells_sprite.visible = true
#						print("perfect! Here's a perfect gel band sprite with short ladders for well ", i, ", fragment size, ",fragment_size, " !")
#						continue
#					if gel.gel_concentration == 2.0 and (fragment_size >= 0.1 and fragment_size <=2.0) and (gel.well_capacity >gel.well_max_capacity/2.0 and gel.well_capacity <=gel.well_max_capacity) and gel.voltage_run_time == 20.0 and gel.correct_comb_placement == true and gel.correct_gel_mixing == true and gel.correct_gel_temperature == true and gel.gel_analysis_asap == true and gel.voltage == 120:
#						band_texture = load("res://textures/gel_bands/Gel_Well_Top_View_PERFECT.svg")
#						base_gel_sprite.visible = true
#						base_wells_sprite.visible = true
#						print("perfect! Here's a perfect gel band sprite with short ladders for well ", i, ", fragment size, ",fragment_size, " !")
#						continue
#					#Conditions for singular well invisible gel bands
#					if gel.well_capacity <=gel.well_max_capacity/2.0:
#						base_gel_sprite.visible = true
#						base_wells_sprite.visible = true
#						print("well capacity not full enough gel sprite will be blank")
#						continue
#					# Conditions for fuzzy or diffused gel bands
#					if gel.voltage <120 and fragment_size >= 0.1:
#						band_texture = load("res://textures/gel_bands/Gel_Well_Top_View_DIFFUSED_9slice.svg")
#						base_gel_sprite.visible = true
#						base_wells_sprite.visible = true
#						print("voltage too low! fragment of size", fragment_size, " will have a long fuzzy band")
#						continue
#					if gel.gel_concentration <120 and fragment_size < 0.1:
#						band_texture = load("res://textures/gel_bands/Gel_Well_Top_View_DIFFUSED.svg")
#						base_gel_sprite.visible = true
#						base_wells_sprite.visible = true
#						print("voltage too low! fragment of size", fragment_size, " will have a short fuzzy band")
#						continue
#					if gel.voltage_run_time <20 and fragment_size >= 0.1:
#						band_texture = load("res://textures/gel_bands/Gel_Well_Top_View_DIFFUSED_9slice.svg")
#						base_gel_sprite.visible = true
#						base_wells_sprite.visible = true
#						print("voltage too low! fragment of size", fragment_size, " will have a long fuzzy band")
#						continue
#					if gel.voltage_run_time <20 and fragment_size < 0.1:
#						band_texture = load("res://textures/gel_bands/Gel_Well_Top_View_DIFFUSED_9slice.svg")
#						base_gel_sprite.visible = true
#						base_wells_sprite.visible = true
#						print("voltage too low! fragment of size", fragment_size, " will have a long fuzzy band")
#						continue
#					if gel.gel_concentration < 2.0 and fragment_size >= 0.1 and fragment_size <=2.0:
#						band_texture = load("res://textures/gel_bands/Gel_Well_Top_View_DIFFUSED.svg")
#						base_gel_sprite.visible = true
#						base_wells_sprite.visible = true
#						print("gel concentration too low for 0.1kb-2kb dna size! fragment of size", fragment_size, " will have a short fuzzy band")
#						continue
#					if gel.gel_concentration >2.0 and fragment_size >= 0.1 and fragment_size <=2.0:
#						band_texture = load("res://textures/gel_bands/Gel_Well_Top_View_DIFFUSED.svg")
#						base_gel_sprite.visible = true
#						base_wells_sprite.visible = true
#						print("gel concentration too high for 0.1kb-2kb dna size! fragment of size", fragment_size, " will have a short fuzzy band")
#						continue
#					if gel.gel_concentration < 1.5 and fragment_size >= 0.2 and fragment_size <=3.0:
#						band_texture = load("res://textures/gel_bands/Gel_Well_Top_View_DIFFUSED.svg")
#						base_gel_sprite.visible = true
#						base_wells_sprite.visible = true
#						print("gel concentration too low for 0.2kb-3kb dna size! fragment of size", fragment_size, " will have a short fuzzy band")
#						continue
#					if gel.gel_concentration >1.5 and fragment_size >= 0.2 and fragment_size <=3.0:
#						band_texture = load("res://textures/gel_bands/Gel_Well_Top_View_DIFFUSED.svg")
#						base_gel_sprite.visible = true
#						base_wells_sprite.visible = true
#						print("gel concentration too high for 0.2kb-3kb dna size! fragment of size", fragment_size, " will have a short fuzzy band")
#						continue
#					if gel.gel_concentration < 1.2 and fragment_size >= 0.3 and fragment_size <=7.0:
#						band_texture = load("res://textures/gel_bands/Gel_Well_Top_View_DIFFUSED.svg")
#						base_gel_sprite.visible = true
#						base_wells_sprite.visible = true
#						print("gel concentration too low for 0.3kb-7kb dna size! fragment of size", fragment_size, " will have a short fuzzy band")
#						continue
#					if gel.gel_concentration >1.2 and fragment_size >= 0.3 and fragment_size <=7.0:
#						band_texture = load("res://textures/gel_bands/Gel_Well_Top_View_DIFFUSED.svg")
#						base_gel_sprite.visible = true
#						base_wells_sprite.visible = true
#						print("gel concentration too high for 0.3kb-7kb dna size! fragment of size", fragment_size, " will have a short fuzzy band")
#						continue
#					if gel.gel_concentration < 1.0 and fragment_size >= 0.4 and fragment_size <=8.0:
#						band_texture = load("res://textures/gel_bands/Gel_Well_Top_View_DIFFUSED_9slice.svg")
#						base_gel_sprite.visible = true
#						base_wells_sprite.visible = true
#						print("gel concentration too low for 0.4kb-8kb dna size! fragment of size", fragment_size, " will have a long fuzzy band")
#						continue
#					if gel.gel_concentration >1.0 and fragment_size >= 0.4 and fragment_size <=8.0:
#						band_texture = load("res://textures/gel_bands/Gel_Well_Top_View_DIFFUSED_9slice.svg")
#						base_gel_sprite.visible = true
#						base_wells_sprite.visible = true
#						print("gel concentration too high for 0.4kb-8kb dna size! fragment of size", fragment_size, " will have a long fuzzy band")
#						continue
#					if gel.gel_concentration < 0.7 and fragment_size >= 0.8 and fragment_size <=12.0:
#						band_texture = load("res://textures/gel_bands/Gel_Well_Top_View_DIFFUSED_9slice.svg")
#						base_gel_sprite.visible = true
#						base_wells_sprite.visible = true
#						print("gel concentration too low for 0.8kb-12kb dna size! fragment of size", fragment_size, " will have a long fuzzy band")
#						continue
#					if gel.gel_concentration >0.7 and fragment_size >= 0.8 and fragment_size <=12.0:
#						band_texture = load("res://textures/gel_bands/Gel_Well_Top_View_DIFFUSED_9slice.svg")
#						base_gel_sprite.visible = true
#						base_wells_sprite.visible = true
#						print("gel concentration too high for 0.8kb-12kb dna size! fragment of size", fragment_size, " will have a long fuzzy band")
#						continue
#					if gel.gel_concentration < 0.5 and fragment_size >= 2.0 and fragment_size <=30.0:
#						band_texture = load("res://textures/gel_bands/Gel_Well_Top_View_DIFFUSED_9slice.svg")
#						base_gel_sprite.visible = true
#						base_wells_sprite.visible = true
#						print("gel concentration too low for 2kb-30kb dna size! fragment of size", fragment_size, " will have a long fuzzy band")
#						continue
#					if gel.gel_concentration >0.5 and fragment_size >= 2.0 and fragment_size <=30.0:
#						band_texture = load("res://textures/gel_bands/Gel_Well_Top_View_DIFFUSED_9slice.svg")
#						base_gel_sprite.visible = true
#						base_wells_sprite.visible = true
#						print("gel concentration too high for 2kb-30kb dna size! fragment of size", fragment_size, " will have a long fuzzy band")
#						continue
#					if gel.gel_analysis_asap == false and fragment_size >= 8.0:
#						band_texture = load("res://textures/gel_bands/Gel_Well_Top_View_DIFFUSED.svg")
#						base_gel_sprite.visible = true
#						base_wells_sprite.visible = true
#						print("Too much time passed between electorphoresis and gel analysis! fragment of size", fragment_size, " will have a short fuzzy band")
#						continue
#					if gel.gel_analysis_asap == false and fragment_size < 8.0:
#						band_texture = load("res://textures/gel_bands/Gel_Well_Top_View_DIFFUSED.svg")
#						base_gel_sprite.visible = true
#						base_wells_sprite.visible = true
#						print("Too much time passed between electorphoresis and gel analysis! fragment of size", fragment_size, " will have a short fuzzy band")
#						continue
#					#Conditions for smiley/wavy/smeared bands
#					if gel.correct_gel_temperature == false and fragment_size >= 8.0:
#						band_texture = load("res://textures/gel_bands/Gel_Well_Top_View_WAVY.svg")
#						base_gel_sprite.visible = true
#						base_wells_sprite.visible = true
#						print("gel heated to incorrect temperature! fragment of size", fragment_size, " will have a long wavy band")
#						continue
#					if gel.correct_gel_temperature == false and fragment_size < 8.0:
#						band_texture = load("res://textures/gel_bands/Gel_Well_Top_View_WAVY_2.svg")
#						base_gel_sprite.visible = true
#						base_wells_sprite.visible = true
#						print("gel heated to incorrect temperature! fragment of size", fragment_size, " will have a short wavy band")
#						continue
#					if gel.correct_comb_placement == false and fragment_size >= 8.0:
#						band_texture = load("res://textures/gel_bands/Gel_Well_Top_View_WAVY.svg")
#						base_gel_sprite.visible = true
#						base_wells_sprite.visible = true
#						print("gel comb not placed well correctly! fragment of size", fragment_size, " will have a long wavy band")
#						continue
#					if gel.correct_comb_placement == false and fragment_size < 8.0:
#						band_texture = load("res://textures/gel_bands/Gel_Well_Top_View_WAVY_2.svg")
#						base_gel_sprite.visible = true
#						base_wells_sprite.visible = true
#						print("gel comb not placed well correctly! fragment of size", fragment_size, " will have a short wavy band")
#						continue
#					if gel.well_capacity >gel.well_max_capacity and fragment_size >= 8.0:
#						band_texture = load("res://textures/gel_bands/Gel_Well_Top_View_SMUDGE.svg")
#						base_gel_sprite.visible = true
#						base_wells_sprite.visible = true
#						print("well is flooded! fragment of size", fragment_size, " will have a long smeared band")
#						continue
#					if gel.well_capacity >gel.well_max_capacity and fragment_size < 8.0:
#						band_texture = load("res://textures/gel_bands/Gel_Well_Top_View_SMUDGE_2.svg")
#						base_gel_sprite.visible = true
#						base_wells_sprite.visible = true
#						print("well is flooded! fragment of size", fragment_size, " will have a long smeared band")
#						continue
#				print("Inconclusive results.")
#			display_blank_gel_bands()
#
#func display_gel_bands() -> void:
#	#Conditions for entirely invisible gel bands
#	if gel.electrode_correct_placement == false:
#		print("electrodes plugged in backwards! gel sprite will be blank")
#		display_blank_gel_bands()
#	if gel.voltage > 120:
#		print("electrodes plugged in backwards! gel sprite will be blank")
#		display_blank_gel_bands()
#	if gel.voltage_run_time >20:
#		print("voltage run too long! gel sprite will be blank")
#		display_blank_gel_bands()
#	#Well Capacity states
#	analyze_gel(gel)
