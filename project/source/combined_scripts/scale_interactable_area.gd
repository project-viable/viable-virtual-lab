extends InteractableArea

@export var body: LabBody
@export var camera: Camera2D
var is_zoomed_in: bool = false
var tare_weight: float = 0.0
var current_weight: float = 0.0 #in terms of grams

func _physics_process(_delta: float) -> void:
	for body:LabBody in get_parent().find_child("InteractableArea").get_overlapping_bodies():
		if body is LabBody and body.find_child("ContainerComponent"):
			current_weight = (body.find_child("ContainerComponent").container_mass + body.find_child("ContainerComponent").get_substances_mass())
			#print ("get_substances_mass: ", body.find_child("ContainerComponent").get_substances_mass())
			#print ("container_mass: ", body.find_child("ContainerComponent").container_mass)
			
	get_parent().find_child("WeightLabel").text = "%.2f" % [current_weight-tare_weight]
	#print ("current_weight-tare_weight: ", current_weight-tare_weight)
	
	
func _on_area_2d_body_entered(body: Node2D) -> void:
	## We only care about weighing objects that can actually be weighed on a scale in real life.
	## Having this if statement will ensure that when the scale is dragged around the screen it won't try to weigh a shelf or something

	if body is LabBody and body.find_child("ContainerComponent"):
		#The scale menu is under a canvas layer so that it sticks to the bottom left corner of the viewport when visible
		print("something's on the scale!")
		#if body.find_child("ContainerComponent").substances.is_empty():
			#get_parent().find_child("WeightLabel").text = str(body.find_child("ContainerComponent").container_mass) + " g"
		#else:
			#get_parent().find_child("WeightLabel").text = str(body.find_child("ContainerComponent").get_total_volume()) + " g"
		
## Handles when the area is clicked on. If so zoom in on the scale
func _on_scale_use_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event.is_action_pressed("click") and not is_zoomed_in:
		is_zoomed_in = true
		TransitionCamera.target_camera = camera
		
func _input(event: InputEvent) -> void:
	if is_zoomed_in and event.is_action_pressed("ExitCameraZoom"):
		is_zoomed_in = false

func _on_area_2d_body_exited(body: Node2D) -> void:
	get_parent().find_child("WeightLabel").text = "0.0 g"
	tare_weight = 0.0

func _on_tare_button_pressed() -> void:
	tare_weight = current_weight
	print ("current_weight: ", current_weight)
	print ("tare_weight: ", tare_weight)
	
