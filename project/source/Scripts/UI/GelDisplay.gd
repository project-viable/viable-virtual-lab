extends Node2D

export (bool) var show_without_UV = true

var band_prefab = null
var gel_images = []
var band_images = []
var uv_on = false
var gel_has_wells = true
var band_positions = []

var cached_band_errors = []

func _ready():
	band_prefab = load('res://Scenes/UI/GelBand.tscn')
	
	# load relevant images to swap between them later
	gel_images.append(load("res://Images/Gel_Wells.png"))
	gel_images.append(load("res://Images/Gel_Wells_UV.png"))
	gel_images.append(load("res://Images/Gel_NoWells.png"))
	gel_images.append(load("res://Images/Gel_NoWells_UV.png"))
	
	# load gel band images once instead of per band
	band_images.append(load('res://Images/GelBand.png'))
	band_images.append(load('res://Images/GelBand_UV.png'))

#
# NOTE: This function expects a list of lists of the format:
# [ [substance_1_band_1, substance_1_band_2], [substance_1_band_2, substance_2_band_2, substance_1_band_3] ]
# and so on.
#
func update_bands(band_positions_in):
	band_positions = band_positions_in
	var upper_bound = min(len(band_positions), $StartPositions.get_child_count())
	
	# update band positions
	for i in range(upper_bound):
		var well = band_positions[i]
		var start_pos = $StartPositions.get_child(i)
		for j in range(len(well)):
			# handle an individual band position
			var move_vec = Vector2(0, $EndPosition.position.y - $StartPositions.position.y)
			var band_pos_factor = well[j]
			if start_pos.get_children() == []:
				return
			var band_obj = start_pos.get_child(j)
			if(band_obj != null):
				band_obj.position = (move_vec * band_pos_factor)
				
				# manually trigger area events as a backup
				if(band_pos_factor > 1.02):
					_on_BottomRunoffArea_body_entered(band_obj)
				elif(band_pos_factor < -0.2):
					_on_TopRunoffArea_body_entered(band_obj)

func init(gel_mold, has_wells):
	gel_has_wells = has_wells
	update_gel_display()
	band_positions = gel_mold.calculate_positions()
	
	# create new bands as needed
	var upper_bound = min(len(band_positions), $StartPositions.get_child_count())
	
	# temporarily deactivate outlier detection to prevent false-positive errors
	$TopRunoffArea.monitoring = false
	$BottomRunoffArea.monitoring = false
	
	for i in range(upper_bound):
		var well = band_positions[i]
		var start_parent = $StartPositions.get_child(i)
		
		while(start_parent.get_child_count() < len(well)):
			var new_band = band_prefab.instance()
			new_band.position = start_parent.position
			start_parent.add_child(new_band)
	
	$TopRunoffArea.monitoring = true
	$BottomRunoffArea.monitoring = true
	
	# assign each band an index so we can reference it later
	for i in range(upper_bound):
		var well = band_positions[i]
		var start_pos = $StartPositions.get_child(i)
		for j in range(len(well)):
			var band_obj = start_pos.get_child(j)
			if(band_obj != null):
				band_obj.set_band_ids(i, j)

func update_gel_display():
	# update gel image
	if(gel_has_wells):
		if(uv_on):
			$Gel.texture = gel_images[1]
		else:
			$Gel.texture = gel_images[0]
	else:
		if(uv_on):
			$Gel.texture = gel_images[3]
		else:
			$Gel.texture = gel_images[2]
	
	# update display for gel bands
	for start_obj in $StartPositions.get_children():
		for band in start_obj.get_children():
			band.update_display(uv_on, show_without_UV, band_images)

func delete_band(band_obj):
	band_obj.queue_free()

func _on_UVLightButton_pressed():
	uv_on = !uv_on
	update_gel_display()

func _on_TopRunoffArea_body_entered(body):
	#print('Top area entered')
	if(body.is_in_group('Gel Band')):
		# check if this band has already triggered an error
		var already_errored = false
		for error in cached_band_errors:
			if(body.is_same_well(error)):
				already_errored = true
				#print('Band ['+str(body.well_index)+','+str(body.band_index)+'] has already errored, refusing to error again')
				break

		if(!already_errored):
			#print('Sending error for band ['+str(body.well_index)+','+str(body.band_index)+']')
			LabLog.Error("A gel band has run off the top of the gel. You may want to check how you've wired the electrolysis setup.")
		
		cached_band_errors.append([body.well_index, body.band_index])
		delete_band(body)

func _on_BottomRunoffArea_body_entered(body):
	#print('Bottom area entered')
	if(body.is_in_group('Gel Band')):
		# check if this band has already triggered an error
		var already_errored = false
		for error in cached_band_errors:
			if(body.is_same_band(error)):
				already_errored = true
				#print('Band ['+str(body.well_index)+','+str(body.band_index)+'] has already errored, refusing to error again')
				break

		if(!already_errored):
			#print('Sending error for band ['+str(body.well_index)+','+str(body.band_index)+']')
			cached_band_errors.append([body.well_index, body.band_index])
			LabLog.Error("A gel band has run off the bottom of the gel. You may have run the gel for too long, or the gel ratio is too small.")
			delete_band(body)

func _on_CloseButton_pressed():
	close()

func close():
	visible = false
	$TopRunoffArea.monitoring = false
	$BottomRunoffArea.monitoring = false

func open():
	visible = true
	$TopRunoffArea.monitoring = true
	$BottomRunoffArea.monitoring = true
