extends LabObject

export (bool) var positive = true

func _ready():
	if(!positive):
		$Contact.texture = load('res://Images/NegativeContact.png')

func is_positive():
	return positive
