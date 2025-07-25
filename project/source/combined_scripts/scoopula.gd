extends ContainerComponent


func _on_area_2d_body_entered(body: Node2D) -> void:
	#If the scoopula is dragged over a container with a substance in it, the scoopula menu will appear.
	#The scoopula menu is under a canvas layer so that it sticks to the bottom left corner of the viewport when visible
	if body is RigidBody2D and body.find_child("ContainerComponent"):
		$CanvasLayer/Control.visible = true
		set_deferred("freeze", true)
	else:
		$CanvasLayer/Control.visible = false


func _on_slider_dispense_qty_value_changed(value: float) -> void:
	$CanvasLayer/Control/PanelContainer/VBoxContainer/lblDispenseQty.text = str(value) + " mL"	


func _on_btn_scoop_pressed() -> void:
	var vol_to_take: float = $CanvasLayer/Control/PanelContainer/VBoxContainer/sliderDispenseQty.value
	#If the user wants to scoop up over 0 mL, they can interact with scooping system
	if vol_to_take != 0.0 and vol_to_take < self.get_volume():
		for body:RigidBody2D in $Area2D.get_overlapping_bodies():
			if body.find_child("ContainerComponent") and !body.find_child("ContainerComponent").substances.is_empty():
				#Add contents to scoopula and update containers's substance volume
				var temp_container: BasicSubstance = body.find_child("ContainerComponent").substances[0].duplicate()
				body.find_child("ContainerComponent").substances[0].volume -= vol_to_take
				print(body.name, "after being scooped from has volume of: ", body.find_child("ContainerComponent").get_total_volume())
				temp_container.volume = vol_to_take
				self.add(temp_container)
				print("My scoopula after scooping has volume of: ", self.get_total_volume())
				
				$FillSprite.visible = true
				
				##Add contents to scoopula and update containers's substance volume
				#var vol_taken: BasicSubstance = body.substances[0].duplicate()
				#body.substances[0].volume -= vol_to_take
				#vol_taken.volume = vol_to_take
				#add(vol_taken)
			else:
				pass
	else:
		print("either 0 mL or too many ml of powder added to scoopula")
	


func _on_btn_dispense_pressed() -> void:
	if substances.is_empty():
		print("scoopula is empty")
	else:
		#the volume of substance held by the scoopula
		var vol_to_dispense: float = substances[0].get_volume()
		#as long as the scoopula isn't empty, the user can dispense substances from it
		var body:RigidBody2D = $Area2D.get_overlapping_bodies()[1]
		#Add contents to receiving container if it isn't full
		print("body.find_child(ContainerComponent).get_volume(): ", body.find_child("ContainerComponent").get_volume())
		if body.find_child("ContainerComponent").substances.is_empty() or (vol_to_dispense + body.find_child("ContainerComponent").get_total_volume() <=  body.find_child("ContainerComponent").get_volume()):
			#Reset scoopula
			
			var temp_container: ContainerComponent = self.duplicate()
			body.find_child("ContainerComponent").add(temp_container.take_volume(vol_to_dispense))
			substances.clear()
			$FillSprite.visible = false
			print(body.name, " after being dumped into has volume of: ", body.find_child("ContainerComponent").get_total_volume())
		else:
			print(body.name, "is already full")
	
	print("scoopula empty?: ", substances.is_empty())
	
	##the volume of substance held by the scoopula
		#var vol_to_dispense: float = substances[0].get_volume()
		##as long as the scoopula isn't empty, the user can dispense substances from it
		#var body:ContainerComponent = $Area2D.get_overlapping_bodies()[1]
		##Add contents to receiving container if it isn't full
		#if body.substances.is_empty() or (vol_to_dispense + body.substances[0].get_volume() <= body.get_volume()):
			##Reset scoopula
			#var vol_dispensed: BasicSubstance = substances[0].duplicate()
			#vol_dispensed.volume = vol_to_dispense
			#body.add(vol_dispensed)
			#substances.clear()
			#$FillSprite.visible = false
