extends Node
## Provides ways to change the appearance and behavior of the cursor.


signal mode_changed(mode: Mode)
signal virtual_mouse_moved(old_pos: Vector2, new_pos: Vector2)
## Objects in the scene receive [InputEventMouseMotion]s based on the movement of the virtual mouse
## rather than movements of the actual mouse, so if they want to detect non-virtual relative mouse
## motion, they have to do it through this signal rather than through [method Node._input].
signal actual_mouse_moved_relative(actual_relative: Vector2)
## This is the same as [signal actual_mouse_moved_relative], but it gives its relative coordinates
## in world space instead of in screen space, so it can be used for in-world operations. Note that
## this does [i]not[/i] always correspond directly to the actual movement of the virtual cursor. For
## example, if the cursor is at the right edge of the screen and the mouse is moved right, then the
## virtual cursor will not move at all, since its position is clamped to the screen. However,
## [signal virtual_mouse_moved_relative] will report the distance that the cursor [i]would[/i] have
## moved had it not been clamped.
signal virtual_mouse_moved_relative(relative: Vector2)


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

## Position of the virtual cursor in global coordinates. When the game is unpaused, the actual
## hardware cursor is locked in the middle of the screen and hidden, and this cursor is moved
## instead based on the relative movement of the actual cursor.
var virtual_mouse_position: Vector2 = Vector2.ZERO :
	set(v):
		var prev_pos := virtual_mouse_position
		virtual_mouse_position = v
		virtual_mouse_moved.emit(prev_pos, virtual_mouse_position)

## When set to [code]true[/code], the virtual cursor will automatically be moved when the mouse
## moves. If this is set to [code]false[/code], then [Cursor] will cede control of the virtual mouse
## and allow it to be fully manually controlled externally.
var automatically_move_with_mouse: bool = true


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		actual_mouse_moved_relative.emit(event.relative)
		var virtual_relative: Vector2 = event.relative / Game.camera.zoom
		virtual_mouse_moved_relative.emit(virtual_relative)

		if automatically_move_with_mouse:
			virtual_mouse_position += virtual_relative
			var rect := Util.get_camera_world_rect(Game.camera)
			virtual_mouse_position = virtual_mouse_position.clamp(rect.position, rect.end)

## Clamp a virtual mouse position to the visible part of the world.
func clamp_to_screen(pos: Vector2) -> Vector2:
	var rect := Util.get_camera_world_rect(Game.camera)
	return pos.clamp(rect.position, rect.end)

## If moving [member virtual_mouse_position] would still be on-screen, return [param motion]
## unchanged. Otherwise, return
## [codeblock lang=gdscript]
## clamp_to_screen(virtual_mouse_position + motion) - virtual_mouse_position
## [/codeblock]
##
## In other words, this function will convert a mouse motion into one that can be safely added to
## [member virtual_mouse_position] without it leaving the screen.
func clamp_relative_to_screen(motion: Vector2) -> Vector2:
	return clamp_to_screen(virtual_mouse_position + motion) - virtual_mouse_position
