@tool
class_name InteractionPrompt
extends HBoxContainer


const MOUSE_LEFT: Texture2D = preload("res://updated_assets/icons_and_buttons/mouse_left.svg")
const MOUSE_MIDDLE: Texture2D = preload("res://updated_assets/icons_and_buttons/mouse_middle.svg")
const MOUSE_RIGHT: Texture2D = preload("res://updated_assets/icons_and_buttons/mouse_right.svg")


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


func _ready() -> void:
	_update_appearance()

func _update_appearance() -> void:
	%DescriptionLabel.text = description

	if disabled: modulate = Color(1, 1, 1, 0.5)
	else: modulate = Color.WHITE

	$KeyboardKey.hide()
	$MouseButton.hide()

	var was_valid := false
	if input_event is InputEventKey:
		%KeyLabel.text = input_event.as_text_keycode()
		$KeyboardKey.show()
		was_valid = true
	elif input_event is InputEventMouseButton:
		var texture := _mouse_button_to_texture(input_event.button_index)
		if texture:
			$MouseButton.texture.atlas = texture
			$MouseButton.show()
			was_valid = true
		else:
			was_valid = false
	
	if not was_valid:
		$KeyboardKey.show()
		%KeyLabel.text = "UNKNOWN BUTTON"

func _mouse_button_to_texture(button_index: int) -> Texture2D:
	match button_index:
		MOUSE_BUTTON_LEFT: return MOUSE_LEFT
		MOUSE_BUTTON_MIDDLE: return MOUSE_MIDDLE
		MOUSE_BUTTON_RIGHT: return MOUSE_RIGHT
		_: return null
