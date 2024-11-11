extends LabObject

@export var positive: bool = true
var regex := RegEx.new()

func _ready() -> void:
	super()
	if(!positive):
		$Contact.texture = load('res://Images/NegativeContact.png')
	regex.compile("ContactWire")

func is_positive() -> bool:
	return positive

func dispose() -> void:
	# If the CurrentContact is part of a ContactWire, it is preferrable to call dispose() on the parent
	var parentIsContactWire := regex.search(get_parent().name)
	if parentIsContactWire:
		get_parent().dispose()
	else:
		self.queue_free()
