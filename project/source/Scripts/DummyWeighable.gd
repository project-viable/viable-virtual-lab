extends LabObject

var contents: Substance = null
var substance: PackedScene = null

func CheckContents(group: StringName) -> Array[bool]:
	return [contents.is_in_group(group)] if contents else []

func TakeContents(_volume: float = -1) -> Array[Substance]:
	if substance == null:
		return []
	
	var new_content: Substance = substance.instantiate()
	print("Dispensed some of the stored substance")
	return [new_content]
