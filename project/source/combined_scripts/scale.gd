extends RigidBody2D

var tare_weight: float = 0.0
var current_weight: float = 0.0 #in terms of grams

func _physics_process(_delta: float) -> void:
	for node: Node2D in $Area2D.get_overlapping_bodies():
		if node is ContainerComponent:
			current_weight = (node.container_mass + node.get_substances_mass())

	$CanvasLayer/Control/PanelContainer/VBoxContainer/Weight_Value.text = "%.2f" % [current_weight-tare_weight]
	#print ("current_weight-tare_weight: ", current_weight-tare_weight)
	
	
func _on_area_2d_body_entered(body: Node2D) -> void:
	#We only care about weighing objects that can actually be weighed on a scale in real life.
	#Having this if statement will ensure that when the scale is dragged around the screen it won't try to weigh a shelf or something.
	print(body)
	if body is ContainerComponent and body is RigidBody2D:
		#The scale menu is under a canvas layer so that it sticks to the bottom left corner of the viewport when visible
		set_deferred("freeze", true)
		$CanvasLayer/Control.visible = true
		

func _on_area_2d_body_exited(body: Node2D) -> void:
	$CanvasLayer/Control.visible = false
	tare_weight = 0.0

func _on_tare_button_pressed() -> void:
	tare_weight = current_weight
	print ("current_weight: ", current_weight)
	print ("tare_weight: ", tare_weight)
	
