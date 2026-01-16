class_name MenuScreenButton
extends Button
## A button that will push a screen onto a [MenuScreenManager] or pop one.


## The [MenuScreenManager] to push and pop screens from. If not set, then it will automatically be
## set to this node's first [MenuScreenManager] ancestor.
@export var menu_screen_manager: MenuScreenManager

## The [MenuScreen] to push. If this is not set, then pressing this button will pop instead.
@export var menu_screen: MenuScreen


func _enter_tree() -> void:
	pressed.connect(_on_pressed)

func _ready() -> void:
	if not menu_screen_manager:
		menu_screen_manager = Util.find_ancestor_of_type(self, MenuScreenManager)

func _on_pressed() -> void:
	if menu_screen: menu_screen.push()
	elif menu_screen_manager: menu_screen_manager.pop_screen()
