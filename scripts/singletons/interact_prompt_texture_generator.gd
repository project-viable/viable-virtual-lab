extends Node


const INTERACTION_PROMPT_SCENE: PackedScene = preload("uid://bqq24b1qxt4r7")
const DEFAULT_TEXTURE: Texture2D = preload("uid://b2u2vyu06gaor")


var _action_prompt_info: Dictionary[StringName, PromptInfo] = {}
@onready var _vp_texture: ViewportTexture = $SubViewport.get_texture()


func _enter_tree() -> void:
	for a in InputMap.get_actions():
		var info := PromptInfo.new()
		info.texture = AtlasTexture.new()
		_action_prompt_info[a] = info

func _ready() -> void:
	for a: StringName in _action_prompt_info.keys():
		var info: PromptInfo = _action_prompt_info[a]
		var event := InputEventAction.new()
		event.action = a

		info.prompt = INTERACTION_PROMPT_SCENE.instantiate()
		info.prompt.input_event = event
		info.prompt.auto_update_pressed = true
		%Prompts.add_child(info.prompt)

		info.texture.atlas = _vp_texture
		RuntimeResourcePathManager.register(info.texture)

	%Prompts.resized.connect(_update_textures)
	for info: PromptInfo in _action_prompt_info.values():
		info.prompt.resized.connect(_update_textures)

func get_texture_for_action_prompt(action: StringName) -> Texture2D:
	var info: PromptInfo = _action_prompt_info.get(action)
	if info: return info.texture
	else: return DEFAULT_TEXTURE

# Update the viewport texture and atlases to match the current positions.
func _update_textures() -> void:
	$SubViewport.size = %Prompts.get_rect().size
	for info: PromptInfo in _action_prompt_info.values():
		info.texture.region = (%Prompts.get_global_transform_with_canvas() * info.prompt.get_rect())

class PromptInfo:
	var prompt: InteractionPrompt
	var texture: AtlasTexture
