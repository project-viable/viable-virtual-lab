extends ContainerComponent

func _init() -> void:
	#setting mass in terms of grams
	set_container_mass(25.0)
	var agarose_powder:SubstanceInstance = SubstanceInstance.new()
	add(agarose_powder)
	#setting agarose powder volume in terms of mL
	agarose_powder.set_volume(4.0)
	pass
