extends Node
## Provides ways to change the appearance and behavior of the cursor.


signal mode_changed(mode: Mode)
signal virtual_mouse_moved(old_pos: Vector2, new_pos: Vector2)
## Emitted when [member virtual_mouse_base_position] changes.
signal virtual_mouse_base_moved(old_pos: Vector2, new_pos: Vector2)
## Objects in the scene receive [InputEventMouseMotion]s based on the movement of the virtual mouse
## rather than movements of the actual mouse, so if they want to detect non-virtual relative mouse
## motion, they have to do it through this signal rather than through [method Node._input]. Note
## that [param actual_relative] already has the mouse sensitivity applied to it, so this isn't the
## [i]actual[/i] actual mouse.
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


## The appearance of the cursor. If [member mode] is set to [constant Mode.POINTER], then
## [member virtual_mouse_position] will be at the tip of the index finger. If it is set to
## [constant Mode.OPEN] or [constant Mode.CLOSED], then [member virtual_mouse_position] will be in
## the center of the palm. This means that setting [member mode] can result in
## [member virtual_mouse_position] moving and [signal virtual_mouse_moved] being fired.
var mode: Mode :
	set(v):
		var was_pointer := mode == Mode.POINTER
		var is_pointer := v == Mode.POINTER
		var prev_pos := virtual_mouse_position

		mode = v

		mode_changed.emit(v)
		# Only say it moved if the hotspot moved.
		if is_pointer != was_pointer:
			virtual_mouse_moved.emit(prev_pos, virtual_mouse_position)


## The position where the virtual cursor is drawn, in global coordinates. This is [i]always[/i] at
## the position where the index finger would be in the sprite, even for [constant Mode.OPEN] and
## [constant Mode.CLOSED]. Unlike [member virtual_mouse_position], this will never change when
## setting [member mode]. However, this can change when the camera zooms, since the in-world size
## of the cursor changes when zooming.
var virtual_mouse_base_position: Vector2 :
	set(v):
		var prev_pos := virtual_mouse_position
		var prev_base_pos := virtual_mouse_base_position
		_virtual_mouse_base_position = v
		virtual_mouse_base_moved.emit(prev_base_pos, virtual_mouse_base_position)
		virtual_mouse_moved.emit(prev_pos, virtual_mouse_position)

	get():
		return _virtual_mouse_base_position


## Position of the virtual cursor in global coordinates. When the game is unpaused, the actual
## hardware cursor is locked in the middle of the screen and hidden, and this cursor is moved
## instead based on the relative movement of the actual cursor. As long as this is still in the
## visible part of the screen, this will never change when the camera is moved, meaning that the
## camera can zoom in on a held object without moving it around.
var virtual_mouse_position: Vector2 = Vector2.ZERO :
	set(v):
		virtual_mouse_base_position = v - _get_offset_from_base()
	get():
		return _virtual_mouse_base_position + _get_offset_from_base()

## When set to [code]true[/code], the virtual cursor will automatically be moved when the mouse
## moves. If this is set to [code]false[/code], then [Cursor] will cede control of the virtual mouse
## and allow it to be fully manually controlled externally.
var automatically_move_with_mouse: bool = true


var _virtual_mouse_base_position: Vector2 = Vector2.ZERO


func _input(event: InputEvent) -> void:
	# If we still allow mouse movement when the mouse isn't captured, it ends up looking like the OS
	# cursor is "desynced" with the virtual cursor, which is confusing. If we disable mouse movement
	# completely, then it's more clear that they need to click into the game to re-engage the
	# cursor.
	if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED: return

	if event is InputEventMouseMotion:
		var sensitivity_multiplier: float = \
				lerp(0.1, 1.0, GameSettings.mouse_sensitivity + 1) \
				if GameSettings.mouse_sensitivity < 0 \
				else lerp(1.0, 3.0, GameSettings.mouse_sensitivity)

		var base_mouse_movement: Vector2 = event.relative * sensitivity_multiplier

		actual_mouse_moved_relative.emit(base_mouse_movement)
		var virtual_relative: Vector2 = base_mouse_movement / Game.camera.zoom
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

# Offset of the virtual mouse position from the virtual base position, in world coordinates.
func _get_offset_from_base() -> Vector2:
	if mode == Mode.POINTER: return Vector2.ZERO
	else: return Game.main.get_virtual_cursor_palm_world_offset()
