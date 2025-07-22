extends ContainerComponent


func _on_area_2d_body_entered(body: Node2D) -> void:
	#If the scoopula is dragged over a container with a substance in it, the scoopula menu will appear.
	#The scoopula menu is under a canvas layer so that it sticks to the bottom left corner of the viewport when visible
	if body is ContainerComponent and body.name != "Scoopula":
		$CanvasLayer/Control.visible = true
		set_deferred("freeze", true)
	else:
		$CanvasLayer/Control.visible = false


func _on_slider_dispense_qty_value_changed(value: float) -> void:
	$CanvasLayer/Control/PanelContainer/VBoxContainer/lblDispenseQty.text = str(value) + " mL"	


func _on_btn_scoop_pressed() -> void:
	var vol_to_take: float = $CanvasLayer/Control/PanelContainer/VBoxContainer/sliderDispenseQty.value
	#If the user wants to scoop up over 0 mL, they can interact with scooping system
	if vol_to_take != 0.0 or vol_to_take < self.get_volume():
		for body:ContainerComponent in $Area2D.get_overlapping_bodies():
			if !body.substances.is_empty():
				$FillSprite.visible = true
				
				#Add contents to scoopula and update containers's substance volume
				body.substances[0].set_volume(body.substances[0].get_volume()-vol_to_take)
				var temp: SubstanceInstance = SubstanceInstance.new()
				temp.set_volume(vol_to_take)
				var vol_taken: SubstanceInstance = temp
				add(vol_taken)
				print("new agarose bottle powder volume: ", body.substances[0].get_volume())
			else:
				pass
	else:
		print("either 0ml or too many ml of powder added to scoopula")


func _on_btn_dispense_pressed() -> void:
	if substances.is_empty():
		pass
	else:
		#the volume of substance held by the scoopula
		var vol_to_dispense: float = substances[0].get_volume()
		#as long as the scoopula isn't empty, the user can dispense substances from it
		if vol_to_dispense != 0.0:
			for body:ContainerComponent in $Area2D.get_overlapping_bodies():
					#Add contents to receiving container if it isn't full
					if body.substances.is_empty() or (vol_to_dispense + body.substances[0].get_volume() <= body.get_volume()):
						#Reset scoopula
						body.add(take_volume(vol_to_dispense))
						body.substances[0].set_volume(body.substances[0].get_volume()+vol_to_dispense)
						print(body.name, " substances volume now: ", body.substances[0].get_volume())
						substances.clear()
						$FillSprite.visible = false
					else:
						print(body.name, "is already full")
			
			print("scoopula empty?: ", substances.is_empty())
	
