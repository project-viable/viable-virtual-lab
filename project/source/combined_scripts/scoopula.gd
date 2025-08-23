extends LabBody

func _on_interactable_area_body_entered(body: Node2D) -> void:
	#If the scoopula is dragged over a container with a substance in it, the scoopula menu will appear.
	#The scoopula menu is under a canvas layer so that it sticks to the bottom left corner of the viewport when visible

	if body is LabBody and body.find_child("ContainerComponent") and body.name != "Scoopula":
		$CanvasLayer/Control.visible = true
		$CanvasLayer/Control/PanelContainer/VBoxContainer/sliderDispenseQty.grab_focus()
		
func _on_interactable_area_body_exited(body: Node2D) -> void:
	$CanvasLayer/Control.visible = false


func _on_slider_dispense_qty_value_changed(value: float) -> void:
		if Input.is_action_pressed("KEY_LEFT"):
			value += 0.001
		if Input.is_action_pressed("KEY_RIGHT"):
			if value > -0.001:
				value -= 0.001
		$CanvasLayer/Control/PanelContainer/VBoxContainer/lblDispenseQty.text = str(value) + " mL"	
	


func _on_interactable_area_input_event_dispense(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT and event.double_click:
			if event.pressed:
				if self.find_child("ContainerComponent").substances.is_empty():
					print("scoopula is empty")
				else:
					#the volume of substance held by the scoopula
					var vol_to_dispense: float = self.find_child("ContainerComponent").substances[0].get_volume()
					#as long as the scoopula isn't empty, the user can dispense substances from it
					var body:LabBody = $InteractableArea.get_overlapping_bodies()[1]
					#Add contents to receiving container if it isn't full
					#print("body.find_child(ContainerComponent).get_volume(): ", body.find_child("ContainerComponent").get_volume())
					if body.find_child("ContainerComponent").substances.is_empty() or (vol_to_dispense + body.find_child("ContainerComponent").get_total_volume() <=  body.find_child("ContainerComponent").get_volume()):
						#Reset scoopula
						
						var temp_container: ContainerComponent = self.find_child("ContainerComponent").duplicate()
						body.find_child("ContainerComponent").add(temp_container.take_volume(vol_to_dispense))
						self.find_child("ContainerComponent").substances.clear()
						$FillSprite.visible = false
						print(body.name, " after being dumped into has volume of: ", body.find_child("ContainerComponent").get_total_volume())
					else:
						print(body.name, "is already full")
				
				print("scoopula empty?: ", self.find_child("ContainerComponent").substances.is_empty())


func _on_interactable_area_input_event_scoop(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			if event.pressed:
				var vol_to_take: float = $CanvasLayer/Control/PanelContainer/VBoxContainer/sliderDispenseQty.value
				#If the user wants to scoop up over 0 mL, they can interact with scooping system
				if vol_to_take != 0.0 and vol_to_take < self.find_child("ContainerComponent").get_volume():
					for body:LabBody in $InteractableArea.get_overlapping_bodies():
						if body.find_child("ContainerComponent") and !body.find_child("ContainerComponent").substances.is_empty():
							#Add contents to scoopula and update containers's substance volume
							var temp_container: BasicSubstance = body.find_child("ContainerComponent").substances[0].duplicate()
							body.find_child("ContainerComponent").substances[0].volume -= vol_to_take
							#print(body.name, "after being scooped from has volume of: ", body.find_child("ContainerComponent").get_total_volume())
							temp_container.volume = vol_to_take
							self.find_child("ContainerComponent").add(temp_container)
							#print("My scoopula after scooping has volume of: ", self.find_child("ContainerComponent").get_total_volume())
							
							$FillSprite.visible = true
						else:
							pass
				else:
					print("either 0 mL or too many ml of powder added to scoopula")
