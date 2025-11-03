## Represents an interaction that an object can perform. This is used for displaying button prompts
## and interaction directions.
class_name InteractInfo
extends Resource


enum Kind
{
	PRIMARY, ## Left click by default.
	SECONDARY, ## Right click by default.
	TERTIARY, ## Shift by default.
	INSPECT, ## E by default. Used to zoom in on things.
	LEFT, ## A by default.
	RIGHT, ## D by default.
}


## variable holding the type of interaction. Primary by default.
@export var kind: Kind = Kind.PRIMARY

## Displayed in the button prompt.
@export var description: String = ""

## If this is set to [code]false[/code], then this interaction can be [i]targeted[/i], but pressing
## the button will not do anything. Setting this to [code]false[/code] will [i]also[/i] show a
## greyed out button prompt. As an example, the pipette can't interact with the pipette tip box when
## it already has a tip, so it's better to show a greyed out button prompt that says something like
## "Left click: Add tip (already has tip).
@export var allowed: bool = true


func _init(p_kind: Kind = Kind.PRIMARY, p_description: String = "", p_allowed: bool = true) -> void:
	kind = p_kind
	description = p_description
	allowed = p_allowed

## Get the [StringName] of the input action associated with an interaction kind.
static func kind_to_action(k: Kind) -> StringName:
	match k:
		Kind.PRIMARY: return &"interact_primary"
		Kind.SECONDARY: return &"interact_secondary"
		Kind.TERTIARY: return &"interact_tertiary"
		Kind.INSPECT: return &"interact_inspect"
		Kind.LEFT: return &"interact_left"
		Kind.RIGHT: return &"interact_right"
		_: return &""
