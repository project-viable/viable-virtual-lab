extends InteractableArea

@export var body: LabBody
@export var camera: Camera2D
var is_zoomed_in: bool = false
var tare_weight: float = 0.0
var current_weight: float = 0.0 #in terms of grams

#func _physics_process(_delta: float) -> void:
	#for node: Node2D in $Area2D.get_overlapping_bodies():
		#if node is RigidBody2D and node.find_child("ContainerComponent"):
			#current_weight = (node.find_child("ContainerComponent").container_mass + node.find_child("ContainerComponent").get_substances_mass())
			#print ("get_substances_mass: ", node.find_child("ContainerComponent").get_substances_mass())
			#print ("container_mass: ", node.find_child("ContainerComponent").container_mass)
			#
	# $CanvasLayer/Control/PanelContainer/VBoxContainer/Weight_Value.text = "%.2f" % [current_weight-tare_weight]
	#print ("current_weight-tare_weight: ", current_weight-tare_weight)
	
	
func _on_area_2d_body_entered(body: Node2D) -> void:
	## We only care about weighing objects that can actually be weighed on a scale in real life.
	## Having this if statement will ensure that when the scale is dragged around the screen it won't try to weigh a shelf or something
	if body is LabBody and body.find_child("ContainerComponent"):
		#The scale menu is under a canvas layer so that it sticks to the bottom left corner of the viewport when visible
		print("something's on the scale!")
		
## Handles when the area is clicked on. If so zoom in on the scale
func _on_scale_use_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event.is_action_pressed("click") and not is_zoomed_in:
		is_zoomed_in = true
		TransitionCamera.target_camera = camera

func _on_area_2d_body_exited(body: Node2D) -> void:
	$CanvasLayer/Control.visible = false
	tare_weight = 0.0

func _on_tare_button_pressed() -> void:
	tare_weight = current_weight
	print ("current_weight: ", current_weight)
	print ("tare_weight: ", tare_weight)
	
