extends Node
## Provides ways to change the appearance and behavior of the cursor.


signal mode_changed(mode: Mode)


enum Mode
{
	POINTER, ## Default pointer.
	OPEN, ## Open hand, used when hovering over something.
	CLOSED, ## Closed hand, used when something is held.
}


var mode: Mode :
	set(v):
		mode = v
		mode_changed.emit(v)

## When set to true, the actual cursor will be represented with a small circle, and the hand will be
## drawn at [member custom_hand_position].
var use_custom_hand_position: bool = false
var custom_hand_position: Vector2
