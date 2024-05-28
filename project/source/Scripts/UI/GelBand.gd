extends KinematicBody2D

var well_index = -1
var band_index = -1

func set_band_ids(well_id, band_id):
	well_index = well_id
	band_index = band_id

func is_same_band(band_data):
	return (band_data[0] == well_index && band_data[1] == band_index)

func update_display(uv_on, show_without_UV, textures):
	var tex_id = (1 if uv_on else 0) # another weird godot-style ternary
	$Sprite.texture = textures[tex_id]
	
	if(!show_without_UV):
		visible = uv_on
	else:
		visible = true

func move_band(move_vec):
	move_and_slide(move_vec)
