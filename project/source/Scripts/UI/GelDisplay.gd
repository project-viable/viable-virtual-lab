extends Node2D

@export var show_without_uv: bool = false

var band_prefab: PackedScene = null
var gel_images: Array[Texture2D] = []
var band_images: Array[Texture2D] = []
var uv_on: bool = false
var gel_has_wells: bool = true

# TODO (update): This should be `Array[Array[float]]`.
var band_positions: Array[Array] = []

# TODO (update): Technically, this should be `Array[Array[int]]`. But actually, it would be better
# represented as `Array[Tuple[int, int]]`, where the first element of each tuple is the well index
# and the second is the band index. Therefore, we should consider using a class to represent a band
# error tuple.
var cached_band_errors: Array[Array] = []

func _ready() -> void:
	band_prefab = load('res://Scenes/UI/GelBand.tscn')
	
	# load relevant images to swap between them later
	gel_images.append(load("res://Images/Gel_Wells.png"))
	gel_images.append(load("res://Images/Gel_Wells_UV.png"))
	gel_images.append(load("res://Images/Gel_NoWells.png"))
	gel_images.append(load("res://Images/Gel_NoWells_UV.png"))
	
	# load gel band images once instead of per band
	band_images.append(load('res://Images/GelBand.png'))
	band_images.append(load('res://Images/GelBand_UV.png'))
	
	self.global_position = get_viewport_rect().size / 2

#
# NOTE: This function expects a list of lists of the format:
# [ [substance_1_band_1, substance_1_band_2], [substance_1_band_2, substance_2_band_2, substance_1_band_3] ]
# and so on.
#
func update_bands(band_positions_in: Array[Array]) -> void:
	band_positions = band_positions_in
	var upper_bound: int = min(len(band_positions), $StartPositions.get_child_count())
	
	# update band positions
	for i in range(upper_bound):
		var well: Array[float] = band_positions[i]
		var start_pos: Node = $StartPositions.get_child(i)
		for j in range(len(well)):
			# handle an individual band position
			var move_vec := Vector2(0, $EndPosition.position.y - $StartPositions.position.y)
			var band_pos_factor := well[j]
			if start_pos.get_children() == [] || j == len(start_pos.get_children()):
				return
			var band_obj := start_pos.get_child(j)
			if(band_obj != null):
				band_obj.position = (move_vec * band_pos_factor)
				
				# manually trigger area events as a backup
				if(band_pos_factor > 1.02):
					_on_BottomRunoffArea_body_entered(band_obj)
				elif(band_pos_factor < -0.2):
					_on_TopRunoffArea_body_entered(band_obj)

func init(gel_mold: GelMoldSubsceneManager, has_wells: bool) -> void:
	gel_has_wells = has_wells
	update_gel_display()
	band_positions = gel_mold.calculate_positions()
	
	# create new bands as needed
	var upper_bound: int = min(len(band_positions), $StartPositions.get_child_count())
	
	# temporarily deactivate outlier detection to prevent false-positive errors
	$TopRunoffArea.monitoring = false
	$BottomRunoffArea.monitoring = false
	
	for i in range(upper_bound):
		var well := band_positions[i]
		var start_parent: Node = $StartPositions.get_child(i)
		
		while(start_parent.get_child_count() < len(well)):
			var new_band := band_prefab.instantiate()
			new_band.position = start_parent.position
			start_parent.add_child(new_band)
	
	$TopRunoffArea.monitoring = true
	$BottomRunoffArea.monitoring = true
	
	# assign each band an index so we can reference it later
	for i in range(upper_bound):
		var well: Array[float] = band_positions[i]
		var start_pos: Node = $StartPositions.get_child(i)
		for j in range(len(well)):
			var band_obj := start_pos.get_child(j)
			if(band_obj != null):
				band_obj.set_band_ids(i, j)
				if j != (len(well) - 1):
					band_obj.visible = false
				else:
					band_obj.visible = true

func update_gel_display() -> void:
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
		var counter := 0
		for band in start_obj.get_children():
			var last_band := (counter == start_obj.get_child_count() - 1)
			band.update_display(uv_on, show_without_uv, band_images, last_band)
			counter += 1

func delete_band(band_obj: Node2D) -> void:
	band_obj.queue_free()

func _on_UVLightButton_pressed() -> void:
	uv_on = !uv_on
	update_gel_display()

func _on_TopRunoffArea_body_entered(body: Node2D) -> void:
	if(body.is_in_group('Gel Band')):
		# check if this band has already triggered an error
		var already_errored := false
		for error in cached_band_errors:
			if(body.is_same_well(error)):
				already_errored = true
				#print('Band ['+str(body.well_index)+','+str(body.band_index)+'] has already errored, refusing to error again')
				break

		if(!already_errored):
			#print('Sending error for band ['+str(body.well_index)+','+str(body.band_index)+']')
			LabLog.error("A gel band has run off the top of the gel. You may want to check how you've wired the electrolysis setup.")
		
		cached_band_errors.append([body.well_index, body.band_index])
		delete_band(body)

func _on_BottomRunoffArea_body_entered(body: Node2D) -> void:
	#print('Bottom area entered')
	if(body.is_in_group('Gel Band')):
		# check if this band has already triggered an error
		var already_errored := false
		for error in cached_band_errors:
			if(body.is_same_well(error)):
				already_errored = true
				#print('Band ['+str(body.well_index)+','+str(body.band_index)+'] has already errored, refusing to error again')
				break

		if(!already_errored):
			#print('Sending error for band ['+str(body.well_index)+','+str(body.band_index)+']')
			LabLog.error("A gel band has run off the bottom of the gel. You may have run the gel for too long, or the gel ratio is too small.")
		
		cached_band_errors.append([body.well_index, body.band_index])	
		delete_band(body)

func _on_CloseButton_pressed() -> void:
	close()

func close() -> void:
	visible = false
	$TopRunoffArea.monitoring = false
	$BottomRunoffArea.monitoring = false

func open() -> void:
	visible = true
	$TopRunoffArea.monitoring = true
	$BottomRunoffArea.monitoring = true
