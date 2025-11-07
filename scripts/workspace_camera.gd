class_name WorkspaceCamera
extends Camera2D
## Denotes a "workspace". A lab might have multiple workspaces arranged horizontally, which can be
## moved between with the A and D keys.


## If set to [code]true[/code], this workspace will be made the current one when the module is
## loaded.
@export var is_main_workspace: bool = false


## The workspace moved to when the user presses the [code]A[/code] button.
@export var left_workspace: WorkspaceCamera
## The workspace moved to when the user presses the [code]D[/code] button.
@export var right_workspace: WorkspaceCamera


func _ready() -> void:
	if is_main_workspace:
		Game.main.move_to_workspace(self)
