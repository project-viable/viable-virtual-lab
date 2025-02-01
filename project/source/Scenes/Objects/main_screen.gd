extends Node2D

var cell_image_width: float 
var cell_image_height: float

func _ready() -> void:
	cell_image_width = $CellImage/Sprite2D.texture.get_width()
	cell_image_height = $CellImage/Sprite2D.texture.get_height()
	
func _process(_delta: float) -> void:
	# Should only be able to move the camera if the screen is actually visible
	if visible:
		var direction:Vector2 = Input.get_vector("CameraLeft", "CameraRight", "CameraUp", "CameraDown")
		$CellImage/Sprite2D.region_rect.position += direction
		if $CellImage/Sprite2D.region_rect.position.x <= 0:
			$CellImage/Sprite2D.region_rect.position.x = 0
		if $CellImage/Sprite2D.region_rect.position.x >= cell_image_width:
			$CellImage/Sprite2D.region_rect.position.x = cell_image_width
			
		if $CellImage/Sprite2D.region_rect.position.y >= cell_image_height:
			$CellImage/Sprite2D.region_rect.position.y = cell_image_height
			
		if $CellImage/Sprite2D.region_rect.position.y <= 0:
			
			$CellImage/Sprite2D.region_rect.position.y = 0 
		
	
