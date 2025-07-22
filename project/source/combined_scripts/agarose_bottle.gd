extends ContainerComponent

func _init() -> void:
	#setting mass in terms of grams
	set_container_mass(1.0)
	var agarose_powder:SubstanceInstance = SubstanceInstance.new()
	add(agarose_powder)
	pass
