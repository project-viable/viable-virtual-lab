extends Node2D
var cell_image_width: float 
var cell_image_height: float
var speed: float = 500

var cell_images: Dictionary = {
	"BPAE": {	
		"10x": preload("res://Images/ImageCells/20250224_bpae_10xA1c1.jpg"),
		"20x": preload("res://Images/ImageCells/20250224_bpae_20xA1c1.jpg"),
		"40x": preload("res://Images/ImageCells/20250224_bpae_40xA1c1.jpg"),
		"100x": preload("res://Images/ImageCells/20250224_bpae_100xA1c1.jpg")
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
	$CellImage/Sprite2D.texture = cell_images["BPAE"][button_value]
