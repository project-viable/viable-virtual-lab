extends LabObject

var contents: Substance = null
var substance: PackedScene = null

func CheckContents(group: String) -> bool:
	return contents.is_in_group(group)

func TakeContents() -> Array[Substance]:
	# TODO (update): We should probably return [] here instead of null. The array type doesn't
	# allow null anyway.
	if substance == null:
		return null
	
	var new_content: Substance = substance.instantiate()
	print("Dispensed some of the stored substance")
	return [new_content]
