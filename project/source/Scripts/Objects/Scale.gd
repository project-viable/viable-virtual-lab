extends "res://Scripts/Objects/LabObject.gd"

#var vis = get_node("Control").visible
var Tare = false
var Weighing = false
var tare_weight = 0.0
var current_weight = 0.0
onready var area = get_node("Area2D")
var objects = []

func TryInteract(others):
	for other in others:
		if other.is_in_group("Weighable"):
			if(!objects.has(other)):
				objects.append(other)
				Weighing = true
				UpdateWeight()
				
			#objects.append(other)
			print(current_weight)
			#update_display()
			get_node("Control").visible = true
			return true
		else:
			print("Not weighable or already being weighed")
	return false

func UpdateWeight():
	var test_weight = 0.0
	for object in objects:
		print(object.get_name())
		test_weight += object.weight
	current_weight = test_weight
	update_display()

func TryActIndependently():
	print("interact test")
	get_node("Control").visible = true
	return true


func _on_Exit_Button_pressed():
	get_node("Control").visible = false
	return true

func _on_Tare_Button_pressed():
	if($Area2D.get_overlapping_bodies().size() != 1):
		for object in $Area2D.get_overlapping_bodies():
			print(object.get_name())
		print("Overlap test")
		tare_weight = current_weight
		Tare = true
		get_node("Control/PanelContainer/VBoxContainer/Weight_Value").text = "%.2f" % (current_weight-tare_weight)
		for object in $Area2D.get_overlapping_bodies():
			if(object.is_in_group("Weighable")):
				if(object.is_in_group("WeighBoat")):
					if(!object.contents.empty()):
						LabLog.Warn("Scale was tared while substances were being weighed, so final measurements may be incorrect", false, false)
	else:
		print("No overlap")
		Tare = false
		tare_weight = 0.0
		UpdateWeight()
		update_display()

func _on_Area2D_body_exited(body):
	#objects.remove(body)
	if(body.is_in_group("Weighable")):
		if(body.is_in_group("WeighBoat")):
			if(!body.contents.empty()):
				if(Tare == false):
					LabLog.Warn("Scale was not tared when weighing, so substance weights may be incorrect", false, false)
		if(objects.has(body)):
			objects.erase(body)
			UpdateWeight()
			update_display()
	if(objects.empty()):
		Weighing = false
	#print("test")

func update_display():
	if(Tare == false):
		get_node("Control/PanelContainer/VBoxContainer/Weight_Value").text = "%.2f" % current_weight
	else:
		get_node("Control/PanelContainer/VBoxContainer/Weight_Value").text = "%.2f" % (current_weight-tare_weight)
