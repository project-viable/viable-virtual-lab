extends LabObject

var slide_images: Dictionary = {}
@export var slide_images_path: String #path to a folder containg the 4 differnt zoom levels for the slide

@export var right_side_up: Texture
@export var right_side_up_oiled: Texture
@export var right_side_down: Texture
@export var right_side_down_oiled: Texture

@export var oiled_up: bool:
	set(value):
		oiled_up = value
		_update_texture()
		
@export var slide_orientation_up: bool:
	set(value):
		slide_orientation_up = value
		_update_texture()
		
func _ready() -> void:
	_update_texture()
	_load_slide_images()
	#TODO need to fix gravity acting on the slides
	
	
# This function is meant to load up the different zoom levels of the slide image, 
# it expects a path to a directory holding 4 jpg images with the zoom level somewhere in the name	
func _load_slide_images() -> void:
	slide_images.clear()
	var magnifications := ["10x", "20x", "40x", "100x"]
	
	var image_dir: DirAccess = DirAccess.open(slide_images_path)
	if image_dir == null:
		push_error("Slide images folder not found: " + slide_images_path)
		return
	else:
		image_dir.list_dir_begin()
		var file_name: String = image_dir.get_next()
		
		while file_name != "":
			if not image_dir.current_is_dir(): # checks that file_name is not a folder
				for mag: String in magnifications:
					if mag in file_name and file_name.ends_with(".jpg"):
						var full_path: String = slide_images_path + "/" + file_name
						var texture: Texture2D = load(full_path)
						slide_images[mag] = texture
			file_name = image_dir.get_next()
			
		image_dir.list_dir_end()
	
func _update_texture() -> void:
	var sprite := $Sprite2D
	if slide_orientation_up:
		sprite.texture = right_side_up_oiled if oiled_up else right_side_up
	else:
		sprite.texture = right_side_down_oiled if oiled_up else right_side_down
		
func get_slide_image() -> Dictionary:
	return slide_images
