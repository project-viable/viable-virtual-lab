extends LabObject

var contents: Substance = null
var substance: PackedScene = null

# TODO (update): The other `CheckContents` functions seem to return an `Array[bool]` with a `bool`
# for each substance contained. This should do the same.
func CheckContents(group: String) -> bool:
	return contents.is_in_group(group)

func TakeContents(_volume: float = -1) -> Array[Substance]:
	if substance == null:
		return []
	
	var new_content: Substance = substance.instantiate()
	print("Dispensed some of the stored substance")
	return [new_content]
