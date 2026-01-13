@tool
class_name SevenSegmentDisplayArray
extends Control
## Allows full strings to be displayed in its children of type [SevenSegmentDisplay].


## The string to display.
@export var string: String :
	set(v):
		string = v
		_update_display()

## If right-aligned, strings will be trimmed to their rightmost characters and padded on the left.
## If not, they will be trimmed to their leftmost characters and padded on the right.
@export var right_aligned: bool = true :
	set(v):
		right_aligned = v
		_update_display()


func _enter_tree() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func _ready() -> void:
	string = string
	right_aligned = right_aligned

func _update_display() -> void:
	var displays: Array[SevenSegmentDisplay] = []
	displays.assign(find_children("", "SevenSegmentDisplay", false))

	var l := displays.size()
	var str_to_display := \
			string.right(l).lpad(l) \
			if right_aligned \
			else string.left(l).rpad(l)
	
	for i in l:
		displays[i].character = str_to_display[i]
