extends LabObject

var contents: Substance = null
var substance: PackedScene = null

func check_contents(group: StringName) -> Array[bool]:
	if contents:
		return [contents.is_in_group(group)]
	else:
		return []

func take_contents(_volume: float = -1) -> Array[Substance]:
	if substance == null:
		return []
	
	var new_content: Substance = substance.instantiate()
	print("Dispensed some of the stored substance")
	return [new_content]
