extends UseComponent

@export var container: ContainerComponent
var vol_to_take: float

func get_interactions(area: InteractableArea) -> Array[InteractInfo]:
	## If the scoopula is empty, return the interaction "scoop"
	if area is ScoopInteractableArea and container.substances.is_empty() and $CanvasLayer/Control/PanelContainer/VBoxContainer/sliderDispenseQty.value == 0.0: 
		return [InteractInfo.new(InteractInfo.Kind.PRIMARY, "Choose mL amount with arrow keys")]
	elif area is ScoopInteractableArea and container.substances.is_empty() and $CanvasLayer/Control/PanelContainer/VBoxContainer/sliderDispenseQty.value != 0.0: 
		return [InteractInfo.new(InteractInfo.Kind.SECONDARY, "Scoop")]
	## If the scoopula is holding something, return the interaction "dispense"
	elif  area is ScoopInteractableArea and !container.substances.is_empty(): 
		return [InteractInfo.new(InteractInfo.Kind.TERNARY, "Dispense")]
	else: return []

func start_use(_area: InteractableArea, _kind: InteractInfo.Kind, event: InputEvent = null) -> void:
	match _kind:
		0:
			## The user will click to interact with the scoopula slider. Using the left and right arrow keys,
			## the user can determine how many mL of a substance the user will pick up.
			print("made it to 0")
			$CanvasLayer/Control/PanelContainer/VBoxContainer/sliderDispenseQty.grab_focus()
			print("made it to here after grabbing focus of slider")
			if event is InputEventKey and event.button_index == KEY_RIGHT and event.pressed():
				print("made it to here after clicking to open slider panel")
				$CanvasLayer/Control/PanelContainer/VBoxContainer/sliderDispenseQty.value += 0.01
				vol_to_take = $CanvasLayer/Control/PanelContainer/VBoxContainer/sliderDispenseQty.value
				_on_slider_dispense_qty_value_changed(vol_to_take)
			if event is InputEventKey and event.button_index == KEY_LEFT and event.pressed() and $CanvasLayer/Control/PanelContainer/VBoxContainer/sliderDispenseQty.value>-0.01:
				$CanvasLayer/Control/PanelContainer/VBoxContainer/sliderDispenseQty.value-= 0.01
		1:
			vol_to_take = $CanvasLayer/Control/PanelContainer/VBoxContainer/sliderDispenseQty.value
			## If the user wants to scoop up over 0 mL, they can interact with scooping system
			if vol_to_take != 0.0 and vol_to_take < container.get_volume():
				for body:LabBody in get_parent().find_child("InteractableArea").get_overlapping_bodies():
					## If the container being interacted with isn't empty but the amount the user wants to scoop is greater than the
					## amount in said container, the user will be notified that they can't do that.
					## Otherwise, the user can scoop like normal
					if !body.find_child("ContainerComponent").substances.is_empty():
						if vol_to_take > body.find_child("ContainerComponent").get_total_volume():
							print("too many ml added to scoopula")
						else:
							## Add contents to scoopula and update containers's substance volume
							var temp_container: BasicSubstance = body.find_child("ContainerComponent").substances[0].duplicate()
							body.find_child("ContainerComponent").substances[0].volume -= vol_to_take
							#print(body.name, "after being scooped from has volume of: ", body.find_child("ContainerComponent").get_total_volume())
							temp_container.volume = vol_to_take
							container.add(temp_container)
							print("My scoopula after scooping has volume of: ", container.get_total_volume())
							
							get_parent().find_child("FillSprite").visible = true
					
					else:
						print("container is empty. There is nothing to scoop")	
			else:
				print("0 mL added to scoopula")
		2:
			if container.substances.is_empty():
				print("scoopula is empty")
			else:
				## the volume of substance held by the scoopula
				var vol_to_dispense: float = container.substances[0].get_volume()
				## As long as the scoopula isn't empty, the user can dispense substances from it
				for body:LabBody in get_parent().find_child("InteractableArea").get_overlapping_bodies():
					## Add contents to receiving container if it isn't full
					if body.name != "Scoopula":
						#print("body.find_child(ContainerComponent).get_volume(): ", body.find_child("ContainerComponent").get_volume())
						if body.find_child("ContainerComponent").substances.is_empty() or (vol_to_dispense + body.find_child("ContainerComponent").get_total_volume() <=  body.find_child("ContainerComponent").get_volume()):
							## Reset scoopula
							
							var temp_container: ContainerComponent =container.duplicate()
							body.find_child("ContainerComponent").add(temp_container.take_volume(vol_to_dispense))
							container.substances.clear()
							get_parent().find_child("FillSprite").visible = false
							print(body.name, " after being dumped into has volume of: ", body.find_child("ContainerComponent").get_total_volume())
						else:
							print(body.name, "is already full")
			
			print("scoopula empty?: ", container.substances.is_empty())
			$CanvasLayer/Control/PanelContainer/VBoxContainer/sliderDispenseQty.value = 0.0

func _on_slider_dispense_qty_value_changed(value: float) -> void:
	$CanvasLayer/Control/PanelContainer/VBoxContainer/lblDispenseQty.text = str(value) + " mL"
