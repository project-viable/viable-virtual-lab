extends "res://Scripts/Objects/LabObject.gd"

var tare: bool = false
var weighing: bool = false
var tare_weight: float = 0.0
var current_weight: float = 0.0

# TODO (update): `area` doesn't appear to be used. Consider removing it.
@onready var area: Area2D = get_node("Area2D")
var objects: Array[LabObject] = []

func TryInteract(others: Array[LabObject]) -> bool:
	for other in others:
		if other.is_in_group("Weighable"):
			if(!objects.has(other)):
				objects.append(other)
				weighing = true
				UpdateWeight()
				
			get_node("Control").visible = true
			return true
		else:
			print("Not weighable or already being weighed")
	return false

func UpdateWeight() -> void:
	var test_weight := 0.0
	for object in objects:
		print(object.get_name() + str(object.mass))
		test_weight += object.mass
	current_weight = test_weight
	
	update_display()

func TryActIndependently() -> bool:
	get_node("Control").visible = true
	return true

# TODO (update): This shouldn't return a value because it gets connected to a signal, which can't
# do anything with the return value.
func _on_Exit_Button_pressed() -> bool:
	get_node("Control").visible = false
	return true

func _on_Tare_Button_pressed() -> void:
	if($Area2D.get_overlapping_bodies().size() != 1):
		for object: Node2D in $Area2D.get_overlapping_bodies():
			print(object.get_name())
		print("Overlap test")
		tare_weight = current_weight
		tare = true
		get_node("Control/PanelContainer/VBoxContainer/Weight_Value").text = "%.2f" % (current_weight-tare_weight)
		for object: Node2D in $Area2D.get_overlapping_bodies():
			if(object.is_in_group("Weighable")):
				if(object.is_in_group("WeighBoat")):
					if(!object.contents.is_empty()):
						LabLog.Warn("Scale was tared while substances were being weighed, so final measurements may be incorrect")
	else:
		print("No overlap")
		tare = false
		tare_weight = 0.0
		UpdateWeight()
		update_display()

func _on_Area2D_body_exited(body: Node2D) -> void:
	if(body.is_in_group("Weighable")):
		if(body.is_in_group("WeighBoat")):
			if(!body.contents.is_empty()):
				if(tare == false):
					LabLog.Warn("Scale was not tared when weighing, so substance weights may be incorrect")
		if(objects.has(body)):
			objects.erase(body)
			UpdateWeight()
			update_display()
	if(objects.is_empty()):
		weighing = false

func update_display() -> void:
	if(tare == false):
		get_node("Control/PanelContainer/VBoxContainer/Weight_Value").text = "%.2f" % current_weight
	else:
		get_node("Control/PanelContainer/VBoxContainer/Weight_Value").text = "%.2f" % (current_weight - tare_weight)
