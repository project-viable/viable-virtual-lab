extends LabObject

export (bool) var positive = true
var regex = RegEx.new()

func _ready():
	if(!positive):
		$Contact.texture = load('res://Images/NegativeContact.png')
	regex.compile("ContactWire")

func is_positive():
	return positive

func dispose():
	var parentIsContactWire = regex.search(get_parent().name)
	if parentIsContactWire:
		get_parent().dispose()
	else:
		self.queue_free()
