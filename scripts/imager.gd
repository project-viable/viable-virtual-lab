extends Node2D


# So the bands aren't so thick.
const BAND_SCALE := Vector2(0.5, 0.1)


var band_texture: Texture2D = preload("res://textures/gel_bands/Gel_Well_Top_View_PERFECT.svg")
var _is_light_on := true
var _is_door_open: bool = false
var results_message: String = ""

@onready var _report_note: ImagerLabReportNote = LabReport.get_or_create_report_note(ImagerLabReportNote)

func _ready() -> void:
	_update_door()
	print("Imager thing: %s" % _report_note.imager_display_texture)

func _draw() -> void:
	if %AttachmentInteractableArea.contained_object is GelTray:
		var gel := %AttachmentInteractableArea.contained_object as GelTray
		if not gel or not _is_light_on: return
		gel.set_gel_state()
		for i:int in gel.num_wells():
			var well_sprite := _get_well_sprite(i + 1)
			var well: ContainerComponent = gel.get_well(i + 1)
			if not well or not well_sprite: continue
			well_sprite.show()

			# There should only be one per container.
			var dna: DNASolutionSubstance = well.find_substance_of_type(DNASolutionSubstance)
			if not dna: continue

			analyze_gel_state(gel, well, i)

			for fragment: DNAFragment in dna.fragments.values():
				# 130 / 0.45 is about the distance in local sprite coordinates to the end of the gel.
				var pos: Vector2 = Vector2.DOWN * fragment.position * 130.0 / 0.45
				var size := band_texture.get_size() * BAND_SCALE
				# Center the bands.
				pos -= size / 2
				band_texture.draw_rect(well_sprite.get_canvas_item(), Rect2(pos, size), false)

func _process(_delta: float) -> void:
	for i in 5:
		var well_sprite := _get_well_sprite(i + 1)
		if well_sprite: well_sprite.queue_redraw()

	queue_redraw()
	Game.debug_overlay.update("results", results_message)

func _get_well_sprite(i: int) -> Node2D:
	return get_node_or_null("%%Well%s" % [i])

func _update_door() -> void:
	if _is_door_open:
		%AttachmentInteractableArea.allow_new_objects = true
		$DoorSelectable.interact_info.description = "Close door"
		%DoorOpen.show()
		%DoorClosed.hide()
		_is_light_on = false
		%UVLabel.theme_type_variation = "OffLabel"
		%UVLabel.text = "UV Off (door open)"

	else:
		%AttachmentInteractableArea.allow_new_objects = false
		$DoorSelectable.interact_info.description = "Open door"
		%DoorOpen.hide()
		%DoorClosed.show()
		_is_light_on = true
		%UVLabel.theme_type_variation = "OnLabel"
		%UVLabel.text = "UV On"

	_maybe_update_report_async()

func _maybe_update_report_async() -> void:
	if $ZoomSelectableArea.is_zoomed_in() and _is_light_on and %AttachmentInteractableArea.contained_object is GelTray:
		# Make sure the subscene has actually been rendered.
		await RenderingServer.frame_post_draw
		_report_note.imager_display_texture = ImageTexture.create_from_image(Game.main.get_subscene_viewport_texture().get_image())


func _on_door_selectable_pressed() -> void:
	_is_door_open = not _is_door_open
	_update_door()

func _on_uv_light_pressed() -> void:
	_is_light_on = not _is_light_on

func analyze_gel_state(gel: GelTray, well: ContainerComponent, i: int) -> void:
	var dna: DNASolutionSubstance = well.find_substance_of_type(DNASolutionSubstance)
	if not dna: return

	for fs: int in dna.fragments.keys():
		var fragment: float = fs / 1000.0
		#Conditions for singular well invisible gel bands
		if gel.gel_state.well_capacities[i] <= (gel.gel_state.well_max_capacity/2.0):
			results_message = str("well %s capacity not full enough gel sprite will be blank" % [i+1])
			continue

		#Perfect results
		elif (gel.gel_state.gel_concentration >= 0.5 and  gel.gel_state.gel_concentration < 0.6)  and (fragment >= 2.0 and fragment <=30.0) and (gel.gel_state.well_capacities[i] >=gel.gel_state.well_max_capacity/2.0 and gel.gel_state.well_capacities[i] <= gel.gel_state.well_max_capacity) and (((gel.gel_state.voltage_run_time/60.0) >= 20.0) and ((gel.gel_state.voltage_run_time/60.0) <21.0)) and gel.correct_gel_mixing == true and gel.correct_gel_temperature == true and gel.gel_state.gel_analysis_asap == true and gel.gel_state.voltage == 120:
			band_texture = load("res://textures/gel_bands/Gel_Well_Top_View_PERFECT_9slice.svg")
			results_message = str("perfect! Here's a perfect gel band sprite with long ladders for well ", i, ", fragment size , ",fragment, " !")
			continue
		elif (gel.gel_state.gel_concentration >= 0.7 and  gel.gel_state.gel_concentration < 0.8) and (fragment >= 0.8 and fragment <=12.0) and (gel.gel_state.well_capacities[i] >=gel.gel_state.well_max_capacity/2.0 and gel.gel_state.well_capacities[i] <=gel.gel_state.well_max_capacity) and (((gel.gel_state.voltage_run_time/60.0) >= 20.0) and ((gel.gel_state.voltage_run_time/60.0) <21.0)) and gel.gel_state.correct_gel_mixing == true and gel.gel_state.correct_gel_temperature == true and gel.gel_state.gel_analysis_asap == true and gel.gel_state.voltage == 120:
				band_texture = load("res://textures/gel_bands/Gel_Well_Top_View_PERFECT_9slice.svg")
				results_message = str("perfect! Here's a perfect gel band sprite with long ladders for well ", i, ", fragment size , ",fragment, " !")
				continue
		elif (gel.gel_state.gel_concentration >= 0.1 and  gel.gel_state.gel_concentration < 0.2) and (fragment >= 0.4 and fragment <=8.0) and (gel.gel_state.well_capacities[i] >=gel.gel_state.well_max_capacity/2.0 and gel.gel_state.well_capacities[i] <=gel.gel_state.well_max_capacity) and (((gel.gel_state.voltage_run_time/60.0) >= 20.0) and ((gel.gel_state.voltage_run_time/60.0) <21.0)) and gel.gel_state.correct_gel_mixing == true and gel.gel_state.correct_gel_temperature == true and gel.gel_state.gel_analysis_asap == true and gel.gel_state.voltage == 120:
			band_texture = load("res://textures/gel_bands/Gel_Well_Top_View_PERFECT_9slice.svg")
			results_message = str("perfect! Here's a perfect gel band sprite with long ladders for well ", i, ", fragment size , ",fragment, " !")
			continue
		elif (gel.gel_state.gel_concentration >= 1.2 and  gel.gel_state.gel_concentration < 1.3) and (fragment >= 0.3 and fragment <=7.0) and (gel.gel_state.well_capacities[i] >=gel.gel_state.well_max_capacity/2.0 and gel.gel_state.well_capacities[i] <=gel.gel_state.well_max_capacity) and (((gel.gel_state.voltage_run_time/60.0) >= 20.0) and ((gel.gel_state.voltage_run_time/60.0) <21.0)) and gel.gel_state.correct_gel_mixing == true and gel.gel_state.correct_gel_temperature == true and gel.gel_state.gel_analysis_asap == true and gel.gel_state.voltage == 120:
			band_texture = load("res://textures/gel_bands/Gel_Well_Top_View_PERFECT_9slice.svg")
			results_message = str("perfect! Here's a perfect gel band sprite with short ladders for well ", i, ", fragment size , ",fragment, " !")
			continue
		elif (gel.gel_state.gel_concentration >= 1.5 and  gel.gel_state.gel_concentration < 1.6) and (fragment >= 0.2 and fragment <=3.0) and (gel.gel_state.well_capacities[i] >=gel.gel_state.well_max_capacity/2.0 and gel.gel_state.well_capacities[i] <=gel.gel_state.well_max_capacity) and (((gel.gel_state.voltage_run_time/60.0) >= 20.0) and ((gel.gel_state.voltage_run_time/60.0) <21.0)) and gel.gel_state.correct_gel_mixing == true and gel.gel_state.correct_gel_temperature == true and gel.gel_state.gel_analysis_asap == true and gel.gel_state.voltage == 120:
			band_texture = load("res://textures/gel_bands/Gel_Well_Top_View_PERFECT.svg")
			results_message = str("perfect! Here's a perfect gel band sprite with short ladders for well ", i, ", fragment size , ",fragment, " !")
			continue
		elif (gel.gel_state.gel_concentration >= 2.0 and  gel.gel_state.gel_concentration < 2.1) and (fragment >= 0.1 and fragment <=2.0) and (gel.gel_state.well_capacities[i] >=gel.gel_state.well_max_capacity/2.0 and gel.gel_state.well_capacities[i] <=gel.gel_state.well_max_capacity) and (((gel.gel_state.voltage_run_time/60.0) >= 20.0) and ((gel.gel_state.voltage_run_time/60.0) <21.0)) and gel.gel_state.correct_gel_mixing == true and gel.gel_state.correct_gel_temperature == true and gel.gel_state.gel_analysis_asap == true and gel.gel_state.voltage == 120:
			band_texture = load("res://textures/gel_bands/Gel_Well_Top_View_PERFECT.svg")
			results_message = str("perfect! Here's a perfect gel band sprite with short ladders for well ", i, ", fragment size , ",fragment, " !")
			continue
		# Conditions for fuzzy or diffused gel bands
		elif gel.gel_state.voltage <120 and fragment >= 0.1:
			band_texture = load("res://textures/gel_bands/Gel_Well_Top_View_DIFFUSED_9slice.svg")
			results_message = str("voltage too low! fragment of size ", fragment, " will have a long fuzzy band")
			continue
		elif gel.gel_state.voltage <120 and fragment < 0.1:
			band_texture = load("res://textures/gel_bands/Gel_Well_Top_View_DIFFUSED.svg")
			results_message = str("voltage too low! fragment of size ", fragment, " will have a short fuzzy band")
			continue
		elif ((gel.gel_state.voltage_run_time/60.0) >= 20.0) and ((gel.gel_state.voltage_run_time/60.0) <21.0) and fragment >= 0.1:
			band_texture = load("res://textures/gel_bands/Gel_Well_Top_View_DIFFUSED_9slice.svg")
			results_message = str("voltage not run long enough! fragment of size ", fragment, " will have a long fuzzy band")
			continue
		elif ((gel.gel_state.voltage_run_time/60.0) >= 20.0) and ((gel.gel_state.voltage_run_time/60.0) <21.0) and fragment < 0.1:
			band_texture = load("res://textures/gel_bands/Gel_Well_Top_View_DIFFUSED_9slice.svg")
			results_message = str("voltage not run long enough! fragment of size ", fragment, " will have a long fuzzy band")
			continue
		elif gel.gel_state.gel_concentration <= 2.0 and fragment >= 0.1 and fragment <=2.0:
			band_texture = load("res://textures/gel_bands/Gel_Well_Top_View_DIFFUSED.svg")
			results_message = str("gel concentration too low for 0.1kb-2kb dna size ! fragment of size ", fragment, " will have a short fuzzy band")
			continue
		elif gel.gel_state.gel_concentration >2.0 and fragment >= 0.1 and fragment <=2.0:
			band_texture = load("res://textures/gel_bands/Gel_Well_Top_View_DIFFUSED.svg")
			results_message = str("gel concentration too high for 0.1kb-2kb dna size ! fragment of size ", fragment, " will have a short fuzzy band")
			continue
		elif gel.gel_state.gel_concentration <= 1.5 and fragment >= 0.2 and fragment <=3.0:
			band_texture = load("res://textures/gel_bands/Gel_Well_Top_View_DIFFUSED.svg")
			results_message = str("gel concentration too low for 0.2kb-3kb dna size ! fragment of size ", fragment, " will have a short fuzzy band")
			continue
		elif gel.gel_state.gel_concentration >1.5 and fragment >= 0.2 and fragment <=3.0:
			band_texture = load("res://textures/gel_bands/Gel_Well_Top_View_DIFFUSED.svg")
			results_message = str("gel concentration too high for 0.2kb-3kb dna size ! fragment of size ", fragment, " will have a short fuzzy band")
			continue
		elif gel.gel_state.gel_concentration <= 1.2 and fragment >= 0.3 and fragment <=7.0:
			band_texture = load("res://textures/gel_bands/Gel_Well_Top_View_DIFFUSED.svg")
			results_message = str("gel concentration too low for 0.3kb-7kb dna size ! fragment of size ", fragment, " will have a short fuzzy band")
			continue
		elif gel.gel_state.gel_concentration >1.2 and fragment >= 0.3 and fragment <=7.0:
			band_texture = load("res://textures/gel_bands/Gel_Well_Top_View_DIFFUSED.svg")
			results_message = str("gel concentration too high for 0.3kb-7kb dna size ! fragment of size ", fragment, " will have a short fuzzy band")
			continue
		elif gel.gel_state.gel_concentration <= 1.0 and fragment >= 0.4 and fragment <=8.0:
			band_texture = load("res://textures/gel_bands/Gel_Well_Top_View_DIFFUSED_9slice.svg")
			results_message = str("gel concentration too low for 0.4kb-8kb dna size ! fragment of size ", fragment, " will have a long fuzzy band")
			continue
		elif gel.gel_state.gel_concentration >1.0 and fragment >= 0.4 and fragment <=8.0:
			band_texture = load("res://textures/gel_bands/Gel_Well_Top_View_DIFFUSED_9slice.svg")
			results_message = str("gel concentration too high for 0.4kb-8kb dna size ! fragment of size ", fragment, " will have a long fuzzy band")
			continue
		elif gel.gel_state.gel_concentration <= 0.7 and fragment >= 0.8 and fragment <=12.0:
			band_texture = load("res://textures/gel_bands/Gel_Well_Top_View_DIFFUSED_9slice.svg")
			results_message = str("gel concentration too low for 0.8kb-12kb dna size ! fragment of size ", fragment, " will have a long fuzzy band")
			continue
		elif gel.gel_state.gel_concentration >0.7 and fragment >= 0.8 and fragment <=12.0:
			band_texture = load("res://textures/gel_bands/Gel_Well_Top_View_DIFFUSED_9slice.svg")
			results_message = str("gel concentration too high for 0.8kb-12kb dna size ! fragment of size ", fragment, " will have a long fuzzy band")
			continue
		elif gel.gel_state.gel_concentration <= 0.5 and fragment >= 2.0 and fragment <=30.0:
			band_texture = load("res://textures/gel_bands/Gel_Well_Top_View_DIFFUSED_9slice.svg")
			results_message = str("gel concentration too low for 2kb-30kb dna size ! fragment of size ", fragment, " will have a long fuzzy band")
			continue
		elif gel.gel_state.gel_concentration >0.5 and fragment >= 2.0 and fragment <=30.0:
			band_texture = load("res://textures/gel_bands/Gel_Well_Top_View_DIFFUSED_9slice.svg")
			results_message = str("gel concentration too high for 2kb-30kb dna size ! fragment of size ", fragment, " will have a long fuzzy band")
			continue
		elif gel.gel_state.gel_analysis_asap == false and fragment >= 8.0:
			band_texture = load("res://textures/gel_bands/Gel_Well_Top_View_DIFFUSED.svg")
			results_message = str("Too much time passed between electorphoresis and gel analysis! fragment of size ", fragment, " will have a short fuzzy band")
			continue
		elif gel.gel_state.gel_analysis_asap == false and fragment < 8.0:
			band_texture = load("res://textures/gel_bands/Gel_Well_Top_View_DIFFUSED.svg")
			results_message = str("Too much time passed between electorphoresis and gel analysis! fragment of size ", fragment, " will have a short fuzzy band")
			continue
		#Conditions for smiley/wavy/smeared bands
		elif gel.gel_state.correct_gel_temperature == false and fragment >= 8.0:
			band_texture = load("res://textures/gel_bands/Gel_Well_Top_View_WAVY.svg")
			results_message = str("gel heated to incorrect temperature! fragment of size ", fragment, " will have a long wavy band")
			continue
		elif gel.gel_state.correct_gel_temperature == false and fragment < 8.0:
			band_texture = load("res://textures/gel_bands/Gel_Well_Top_View_WAVY_2.svg")
			results_message = str("gel heated to incorrect temperature! fragment of size ", fragment, " will have a short wavy band")
			continue
		elif gel.gel_state.well_capacities[i] >gel.gel_state.well_max_capacity and fragment >= 8.0:
			band_texture = load("res://textures/gel_bands/Gel_Well_Top_View_SMUDGE.svg")
			results_message = str("well is flooded! fragment of size ", fragment, " will have a long smeared band")
			continue
		elif gel.gel_state.well_capacities[i] >gel.gel_state.well_max_capacity and fragment < 8.0:
			band_texture = load("res://textures/gel_bands/Gel_Well_Top_View_SMUDGE_2.svg")
			results_message = str("well is flooded! fragment of size ", fragment, " will have a long smeared band")
			continue
		else:
			band_texture = load("res://textures/gel_bands/Gel_Well_Top_View_PERFECT.svg")
			results_message = str("Inconclusive results.")


class ImagerLabReportNote extends LabReportNote:
	# The imager's display (the subscene) as a texture. Only captured when a gel is in the imager
	# and the light is turned on.
	var imager_display_texture: Texture2D = null


	func add_to_label(label: RichTextLabel) -> void:
		label.push_font_size(24)
		label.add_text("Gel result")
		label.pop()
		label.newline()
		label.newline()

		if imager_display_texture:
			label.add_image(imager_display_texture)
		else:
			label.add_text("Gel has not been imaged yet.")
