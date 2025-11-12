extends Node
## Provides ways to change the appearance and behavior of the cursor.


signal mode_changed(mode: Mode)
signal virtual_mouse_moved(old_pos: Vector2, new_pos: Vector2)
signal custom_hand_moved(old_pos: Vector2, new_pos: Vector2)
## Objects in the scene receive [InputEventMouseMotion]s based on the movement of the virtual mouse
## rather than movements of the actual mouse, so if they want to detect non-virtual relative mouse
## motion, they have to do it through this signal rather than through [method Node._input].
signal actual_mouse_moved_relative(actual_relative: Vector2)


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

## When set to true, the actual cursor will be represented with a small circle, and the hand will be
## drawn at [member custom_hand_position].
var use_custom_hand_position: bool = false
var custom_hand_position: Vector2 :
	set(v):
		var prev_pos := custom_hand_position
		custom_hand_position = v
		custom_hand_moved.emit(prev_pos, custom_hand_position)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		actual_mouse_moved_relative.emit(event.relative)
		virtual_mouse_position += event.relative / Game.camera.zoom
		var rect := Util.get_camera_world_rect(Game.camera)
		virtual_mouse_position = virtual_mouse_position.clamp(rect.position, rect.end)
