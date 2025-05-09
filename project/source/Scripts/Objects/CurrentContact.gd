extends LabObject
class_name CurrentContact

@export var positive: bool = true
var regex: RegEx = RegEx.new()

func _ready() -> void:
	super()
	if(!positive):
		$Contact.texture = load('res://Images/NegativeContact.png')
	regex.compile("ContactWire")

func is_positive() -> bool:
	return positive

func dispose() -> void:
	# If the CurrentContact is part of a ContactWire, it is preferrable to call dispose() on the parent
	var parent_is_contact_wire := regex.search(get_parent().name)
	if parent_is_contact_wire:
		get_parent().dispose()
	else:
		self.queue_free()
