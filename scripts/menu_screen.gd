class_name MenuScreen
extends Control
## A single screen in a menu. Should always be a direct child of a [MenuScreenManager].


@onready var _manager := get_parent() as MenuScreenManager


## Push this screen onto the manager's stack.
func push() -> void:
	if _manager: _manager.push_screen(self)
