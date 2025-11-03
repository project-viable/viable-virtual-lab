extends InteractableArea

@export var body: LabBody
@export var camera: Camera2D
var is_zoomed_in: bool = false
var tare_weight: float
var current_weight: float = 0.0 #in terms of grams

func _ready() -> void:
	super()
	Game.main.camera_focus_owner_changed.connect(_on_main_camera_focus_owner_changed)

func _physics_process(_delta: float) -> void:
	## The scale will constantly be waiting to update the display of grams 
	current_weight = 0.0
	for body:LabBody in get_parent().find_child("InteractableArea").get_overlapping_bodies():
		# Don't weigh objects unless they are affected by gravity.
		if not (body is LabBody) or body.physics_mode != LabBody.PhysicsMode.FREE:
			continue

		for c: ContainerComponent in body.find_children("", "ContainerComponent", false):
			current_weight += (c.container_mass + c.get_substances_mass())

	get_parent().find_child("WeightLabel").text = "%.2f" % [current_weight-tare_weight]

## Handles when the area is clicked on. If so zoom in on the scale
func _on_zoom_area_pressed() -> void:
	$"../ZoomArea".enable_interaction = false
	is_zoomed_in = true
	Game.camera.move_to_camera(camera)
	Game.main.set_camera_focus_owner(self)

## Handles when the user wants to zoom back out to the main scene
func _on_main_camera_focus_owner_changed(focus_owner: Node) -> void:
	if is_zoomed_in and focus_owner != self:
		$"../ZoomArea".enable_interaction = true
		is_zoomed_in = false

func _on_tare_button_pressed() -> void:
	tare_weight = current_weight
	print ("current_weight: ", current_weight)
	print ("tare_weight: ", tare_weight)
	
