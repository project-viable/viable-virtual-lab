extends RigidBody2D

#Panel coordinates are (-1075, 231)

var tare_weight: float = 0.0

func _physics_process(_delta: float) -> void:
	
	var current_weight: float = 0.0
	
	#for node: Node2D in $Area2D.get_overlapping_bodies():
		#if node is RigidBody2D:
			#print("something on the scale")
	
	
func _on_area_2d_body_entered(body: Node2D) -> void:
	#We only care about weighing objects that can actually be weighed on a scale in real life.
	#Having this if statement will ensure that when the scale is dragged around the screen it won't try to weigh a shelf or something.
	if body is RigidBody2D:
		$Control.visible = true
	else:
		$Control.visible = false

func _on_area_2d_body_exited(body: Node2D) -> void:
	$Control.visible = false
