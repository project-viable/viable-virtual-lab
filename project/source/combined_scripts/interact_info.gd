## Represents an interaction that an object can perform. This is used for displaying button prompts
## and 
class_name InteractInfo


enum Kind
{
	PRIMARY, ## Left click by default.
	SECONDARY, ## Right click by default.
	TERNARY, ## Shift by default.
	ZOOM, ## Space by default.
	ADJUST_LEFT, ## A by default.
	ADJUST_RIGHT, ## D by default.
}


var kind: Kind = Kind.PRIMARY

## Displayed in the button prompt.
var description: String = ""

## If this is set to [code]false[/code], then this interaction can be [i]targeted[/i], but pressing
## the button will not do anything. Setting this to [code]false[/code] will [i]also[/i] show a
## greyed out button prompt. As an example, the pipette can't interact with the pipette tip box when
## it already has a tip, so it's better to show a greyed out button prompt that says something like
## "Left click: Add tip (already has tip).
var allowed: bool = true


static func kind_to_action(k: Kind) -> StringName:
	match k:
		Kind.PRIMARY: return &"interact_primary"
		Kind.SECONDARY: return &"interact_secondary"
		Kind.TERNARY: return &"interact_ternary"
		Kind.ZOOM: return &"interact_zoom"
		Kind.ADJUST_LEFT: return &"interact_adjust_left"
		Kind.ADJUST_RIGHT: return &"interact_adjust_right"

	return &""


func _init(p_kind: Kind, p_description: String, p_allowed: bool = true) -> void:
	kind = p_kind
	description = p_description
	allowed = p_allowed
