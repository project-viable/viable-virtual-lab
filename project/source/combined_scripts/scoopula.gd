extends ContainerComponent


func _on_area_2d_body_entered(body: Node2D) -> void:
	#If the scoopula is dragged over a container with a substance in it, the fill sprite will appear.
	if body is ContainerComponent:
		if!body.substances.is_empty():
			$FillSprite.visible = true
		$CanvasLayer/Control.visible = true
		set_deferred("freeze", true)
		#The scoopula menu is under a canvas layer so that it sticks to the bottom left corner of the viewport when visible
	else:
		$CanvasLayer/Control.visible = false


func _on_slider_dispense_qty_value_changed(value: float) -> void:
	$CanvasLayer/Control/PanelContainer/VBoxContainer/lblDispenseQty.text = str(value) + " mL"	


func _on_btn_dispense_pressed(body: Node2D) -> void:
	var vol_dispensed: float = $CanvasLayer/Control/PanelContainer/VBoxContainer/sliderDispenseQty.value/substances[0].get_density()
	
	#Add contents to receiving object
	#Update current volume remaining
	var taken_volume: SubstanceInstance = substances[0].take_volume(vol_dispensed)
	if body is ContainerComponent and !body.substances.is_empty():
		body.add(taken_volume)
	else:
		pass
	print(substances[0].get_volume()*substances[0].get_density())
	$FillSprite.visible = false
