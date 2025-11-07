class_name LogMessage
extends Resource

# `LOG` is for general messages - not mistakes, just something you want to log.
#
# `WARNING` is for minor errors that you can continue on from, like putting glass in a normal
# trash can.
#
# `ERROR` is for things you can't recover from.
enum Category
{
	LOG,
	WARNING,
	ERROR
}

@export var category: Category
@export var message: String
@export var hidden: bool
@export var popup: bool

func _init(p_category: Category, p_message: String, p_hidden: bool = false, p_popup: bool = false) -> void:
	category = p_category
	message = p_message
	hidden = p_hidden
	popup = p_popup
