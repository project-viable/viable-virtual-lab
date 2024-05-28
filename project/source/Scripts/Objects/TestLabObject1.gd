extends LabObject

func TryInteract(others):
	for other in others:
		if other.is_in_group("Test LabObject Group"):
			other.ScaleUp()
			return true
	
	return false
