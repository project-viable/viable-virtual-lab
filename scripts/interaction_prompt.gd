@tool
class_name InteractionPrompt
extends HBoxContainer


const MOUSE_LEFT: Texture2D = preload("res://textures/icons_and_buttons/mouse_left.svg")
const MOUSE_MIDDLE: Texture2D = preload("res://textures/icons_and_buttons/mouse_middle.svg")
const MOUSE_RIGHT: Texture2D = preload("res://textures/icons_and_buttons/mouse_right.svg")
const MOUSE_LEFT_PRESSED: Texture2D = preload("res://textures/icons_and_buttons/mouse_left_pressed.svg")
const MOUSE_RIGHT_PRESSED: Texture2D = preload("res://textures/icons_and_buttons/mouse_right_pressed.svg")


## The key or mouse button to display.
@export var input_event: InputEvent:
	set(v):
		input_event = v
		_update_appearance()

## The description of the interaction, displayed next to the key.
@export var description: String = "" :
	set(v):
		description = v
		_update_appearance()

## If this is set to [code]true[/code], then the prompt will be made slightly
## transparent to show that it can't be pressed.
@export var disabled: bool = false :
	set(v):
		disabled = v
		_update_appearance()

## If this is [code]true[/code], then the button icon will display as pressed.
@export var pressed: bool = false:
	set(v):
		pressed = v
		_update_appearance()

## If set to [code]true[/code], then [member pressed] will be automatically
## updated every frame to the actual pressed state of the input according to
## [Input].
@export var auto_update_pressed: bool = false


func _ready() -> void:
	_update_appearance()

func _process(_delta: float) -> void:
	if auto_update_pressed and not Engine.is_editor_hint():
		var new_pressed := _is_actively_pressed(input_event)
		if new_pressed != pressed:
			pressed = new_pressed

func _update_appearance() -> void:
	%DescriptionLabel.visible = description != ""
	%DescriptionLabel.text = description

	if disabled: modulate = Color(1, 1, 1, 0.5)
	else: modulate = Color.WHITE

	# Show an [InputEventAction] as its first binding.
	var input_event_to_show := input_event
	if input_event is InputEventAction:
		var events := InputMap.action_get_events(input_event.action)
		if events:
			input_event_to_show = events.front()

	$KeyUnpressed.hide()
	$KeyPressed.hide()
	$MouseButton.hide()

	var was_valid := false
	if input_event_to_show is InputEventKey:
		_show_text_in_key(_keyboard_key_name(input_event_to_show))
		was_valid = true
	elif input_event_to_show is InputEventMouseButton:
		var texture := _mouse_button_to_texture(input_event_to_show.button_index)
		if texture:
			$MouseButton.texture.atlas = texture
			$MouseButton.show()
			was_valid = true
		else:
			was_valid = false

	if not was_valid:
		_show_text_in_key("(unknown)")

func _show_text_in_key(s: String) -> void:
	if _should_show_as_pressed():
		$KeyPressed/Label.text = s
		$KeyPressed.show()
	else:
		$KeyUnpressed/Label.text = s
		$KeyUnpressed.show()

func _mouse_button_to_texture(button_index: int) -> Texture2D:
	match button_index:
		MOUSE_BUTTON_LEFT:
			if _should_show_as_pressed(): return MOUSE_LEFT_PRESSED
			else: return MOUSE_LEFT
		MOUSE_BUTTON_MIDDLE: return MOUSE_MIDDLE
		MOUSE_BUTTON_RIGHT:
			if _should_show_as_pressed(): return MOUSE_RIGHT_PRESSED
			else: return MOUSE_RIGHT
		_: return null

func _should_show_as_pressed() -> bool:
	return pressed

static func _keyboard_key_name(e: InputEventKey) -> String:
	if e.keycode != KEY_NONE: return e.as_text_keycode()
	elif e.physical_keycode != KEY_NONE: return e.as_text_physical_keycode()
	elif e.key_label != KEY_NONE: return e.as_text_key_label()
	else: return "(unknown)"

static func _is_actively_pressed(e: InputEvent) -> bool:
	if e is InputEventAction:
		return Input.is_action_pressed(e.action)
	elif e is InputEventKey:
		if e.keycode != KEY_NONE:
			return Input.is_key_pressed(e.keycode)
		elif e.physical_keycode != KEY_NONE:
			return Input.is_physical_key_pressed(e.keycode)
		elif e.key_label != KEY_NONE:
			return Input.is_key_label_pressed(e.key_label)
		else:
			return false
	elif e is InputEventMouseButton:
		return Input.is_mouse_button_pressed(e.button_index)
	else:
		return false
