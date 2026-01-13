class_name MenuScreenManager
extends Control
## Manages a set of child [MenuScreen] UI nodes, ensuring that only one can be visible at a time.


## The "main" or "root" menu screen. This is visible if no other screens have been pushed on the
## stack. If not set, this will automatically be set to the first [MenuScreen] child of this node.
@export var primary_screen: MenuScreen

# Stack of visited screens, not including the root screen.
var _screen_stack: Array[MenuScreen] = []


func _ready() -> void:
	if not primary_screen: primary_screen = Util.find_child_of_type(self, MenuScreen)
	_show_screen(primary_screen)

## Attempt to push the screen [param screen] onto the screen stack and make it visible. If
## [param screen] is not a direct child of this node, then it will not be pushed.
func push_screen(screen: MenuScreen) -> void:
	if screen.get_parent() != self: return
	_screen_stack.push_back(screen)
	_show_screen(screen)

## Remove the currently shown screen from the top of the stack and show the previous one. If the
## stack becomes empty, show the primary screen. If the stack was already empty when this function
## was called, do nothing.
func pop_screen() -> void:
	_screen_stack.pop_back()
	if _screen_stack: _show_screen(_screen_stack.back())
	else: _show_screen(primary_screen)

## Remove all screens from the stack and return to the primary screen.
func pop_all_screens() -> void:
	_screen_stack.clear()
	_show_screen(primary_screen)

func is_on_primary_screen() -> bool: return not _screen_stack

# Make [param screen] the actively visible screen.
func _show_screen(screen: MenuScreen) -> void:
	for c: MenuScreen in find_children("", "MenuScreen", false):
		c.hide()
	# Null check to deal with a potentially null primary screen.
	if screen: screen.show()
