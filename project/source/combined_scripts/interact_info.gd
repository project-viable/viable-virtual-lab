## Represents an interaction that an object can perform. This is used for displaying button prompts
## and 
class_name InteractInfo


enum Kind
{
	PRIMARY, ## Left click by default.
	SECONDARY, ## Right click by default.
	TERNARY, ## Enter key by default.
}


var kind: Kind = Kind.PRIMARY

## Displayed in the button prompt.
var description: String = ""


func _init(p_kind: Kind, p_description: String) -> void:
	kind = p_kind
	description = p_description
