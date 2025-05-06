extends LabObject

var has_non_empty_weigh_boat: bool = false
var tare_weight: float = 0.0
var current_weight: float = 0.0

func try_interact(others: Array[LabObject]) -> bool:
	for other in others:
		if other.is_in_group("Weighable"):
			$Control.visible = true
			return true
		else:
			print("Not weighable")
	return false

func _physics_process(_delta: float) -> void:
	current_weight = 0.0
	has_non_empty_weigh_boat = false

	for node: Node2D in $Area2D.get_overlapping_bodies():
		if node is LabObject and node.is_in_group("Weighable"):
			current_weight += node.mass
		if node.is_in_group("WeighBoat") and not node.contents.is_empty():
			has_non_empty_weigh_boat = true

	$Control/PanelContainer/VBoxContainer/Weight_Value.text = "%.2f" % [current_weight - tare_weight]

func try_act_independently() -> bool:
	$Control.visible = true
	return true

func _on_Exit_Button_pressed() -> void:
	$Control.visible = false

func _on_Tare_Button_pressed() -> void:
	tare_weight = current_weight
	if has_non_empty_weigh_boat:
		LabLog.warn("Scale was tared while substances were being weighed, so final measurements may be incorrect")
