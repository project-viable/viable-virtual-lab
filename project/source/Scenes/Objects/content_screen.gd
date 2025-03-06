extends Node2D
var cell_image_width: float 
var cell_image_height: float
var speed: float = 500
var curr_channel: String = "BPAE"
var curr_button_value: String = "10x"

var cell_images: Dictionary = {
	"BPAE": {	
		"10x": preload("res://Images/ImageCells/20250224_bpae_10xA1c1.jpg"),
		"20x": preload("res://Images/ImageCells/20250224_bpae_20xA1c1.jpg"),
		"40x": preload("res://Images/ImageCells/20250224_bpae_40xA1c1.jpg"),
		"100x": preload("res://Images/ImageCells/20250224_bpae_100xA1c1.jpg")
	},
	"Dapi": {
		"10x": preload("res://Images/ImageCells/ImageA1/Dapi/20250224_bpae_10xA1c1.jpg"),
		"20x": preload("res://Images/ImageCells/ImageA1/Dapi/20250224_bpae_20xA1c1.jpg"),
		"40x": preload("res://Images/ImageCells/ImageA1/Dapi/20250224_bpae_40xA1c1.jpg"),
		"100x": preload("res://Images/ImageCells/ImageA1/Dapi/20250224_bpae_100xA1c1.jpg")
	},
	"FITC": {
		"10x": preload("res://Images/ImageCells/ImageA1/FITC/20250224_bpae_10xA1c2.jpg"),
		"20x": preload("res://Images/ImageCells/ImageA1/FITC/20250224_bpae_20xA1c2.jpg"),
		"40x": preload("res://Images/ImageCells/ImageA1/FITC/20250224_bpae_40xA1c2.jpg"),
		"100x": preload("res://Images/ImageCells/ImageA1/FITC/20250224_bpae_100xA1c2.jpg")
	},
	"TRITC": {
		"10x": preload("res://Images/ImageCells/ImageA1/TRITC/20250224_bpae_10xA1c3.jpg"),
		"20x": preload("res://Images/ImageCells/ImageA1/TRITC/20250224_bpae_20xA1c3.jpg"),
		"40x": preload("res://Images/ImageCells/ImageA1/TRITC/20250224_bpae_40xA1c3.jpg"),
		"100x": preload("res://Images/ImageCells/ImageA1/TRITC/20250224_bpae_100xA1c3.jpg")
	},
	"Cy5": {
		"10x": preload("res://Images/ImageCells/ImageA1/Cy5/20250224_bpae_10xA1c4.jpg"),
		"20x": preload("res://Images/ImageCells/ImageA1/Cy5/20250224_bpae_20xA1c4.jpg"),
		"40x": preload("res://Images/ImageCells/ImageA1/Cy5/20250224_bpae_40xA1c4.jpg"),
		"100x": preload("res://Images/ImageCells/ImageA1/Cy5/20250224_bpae_100xA1c4.jpg")
	}
}

var direction: Vector2 = Vector2(0,0)
func _ready() -> void:
	hide()
	cell_image_width = $CellImage/Sprite2D.texture.get_width()
	cell_image_height = $CellImage/Sprite2D.texture.get_height()

	
func _process(delta: float) -> void:
	# Should only be able to move the camera if the screen is actually visible
	if visible:
		#direction = Input.get_vector("CameraLeft", "CameraRight", "CameraUp", "CameraDown")
		$CellImage/Sprite2D.region_rect.position += direction * speed * delta
		
		# Check so the visible image doesnt go past the actual image width and height
		if $CellImage/Sprite2D.region_rect.position.x <= 0:
			$CellImage/Sprite2D.region_rect.position.x = 0
			
		if $CellImage/Sprite2D.region_rect.position.x >= cell_image_width - $CellImage/Sprite2D.region_rect.size.x:
			$CellImage/Sprite2D.region_rect.position.x = cell_image_width - $CellImage/Sprite2D.region_rect.size.x
			
		if $CellImage/Sprite2D.region_rect.position.y >= cell_image_height - $CellImage/Sprite2D.region_rect.size.y:
			$CellImage/Sprite2D.region_rect.position.y = cell_image_height - $CellImage/Sprite2D.region_rect.size.y
			
		if $CellImage/Sprite2D.region_rect.position.y <= 0:
			$CellImage/Sprite2D.region_rect.position.y = 0 


# Change Image Zoom
func _on_macro_panel_button_press(button_value: String) -> void:
	curr_button_value = button_value
	$CellImage/Sprite2D.texture = cell_images[curr_channel][button_value]


func _on_computer_channel_select(channel: String) -> void:
	curr_channel = channel
	$CellImage/Sprite2D.texture = cell_images[channel][curr_button_value]
