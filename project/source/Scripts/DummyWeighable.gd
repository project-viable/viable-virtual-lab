extends LabObject

var contents = null
var substance = null

func CheckContents(group):
	return contents.is_in_group(group)

func TakeContents():
	if substance == null:
		return null
	
	var new_content = substance.instantiate()
	print("Dispensed some of the stored substance")
	return [new_content]
