extends InteractableArea

@export var body: LabBody
@export var camera: Camera2D
var is_zoomed_in: bool = false
var tare_weight: float
var current_weight: float = 0.0 #in terms of grams

func _physics_process(_delta: float) -> void:
	## The scale will constantly be waiting to update the display of grams 
	current_weight = 0.0
	for body:LabBody in get_parent().find_child("InteractableArea").get_overlapping_bodies():
		if body is LabBody and not body.freeze:
			current_weight += (body.find_child("ContainerComponent", false).container_mass + body.find_child("ContainerComponent", false).get_substances_mass())
			#print ("get_substances_mass: ", body.find_child("ContainerComponent").get_substances_mass())
			#print ("container_mass: ", body.find_child("ContainerComponent").container_mass)
			
	get_parent().find_child("WeightLabel").text = "%.2f" % [current_weight-tare_weight]
	#print("tare_weight: ", tare_weight)
	#print ("current_weight-tare_weight: ", current_weight-tare_weight)
	
## Handles when the area is clicked on. If so zoom in on the scale
func _on_scale_use_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event.is_action_pressed("click") and not is_zoomed_in:
		is_zoomed_in = true
		TransitionCamera.target_camera = camera
		
## Handles when the user wants to zoom back out to the main scene
func _input(event: InputEvent) -> void:
	if is_zoomed_in and event.is_action_pressed("ExitCameraZoom"):
		is_zoomed_in = false

func _on_tare_button_pressed() -> void:
	tare_weight = current_weight
	print ("current_weight: ", current_weight)
	print ("tare_weight: ", tare_weight)
	
