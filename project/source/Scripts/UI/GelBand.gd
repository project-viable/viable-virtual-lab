extends CharacterBody2D

var well_index: int = -1
var band_index: int = -1

func set_band_ids(well_id: int, band_id: int) -> void:
	well_index = well_id
	band_index = band_id

func is_same_band(band_data: Array[int]) -> bool:
	return (band_data[0] == well_index && band_data[1] == band_index)

func is_same_well(band_data: Array[int]) -> bool:
	return (band_data[0] == well_index)

func update_display(uv_on: bool, show_without_uv: bool, textures: Array[Texture2D], last_band: bool) -> void:
	var tex_id := (1 if uv_on else 0) # another weird godot-style ternary
	$Sprite2D.texture = textures[tex_id]
	
	if(!show_without_uv):
		visible = uv_on
		
		if last_band:
			visible = true
	else:
		visible = true

func move_band(move_vec: Vector2) -> void:
	set_velocity(move_vec)
	move_and_slide()
