@tool
class_name PreprocessedRichTextLabel
extends RichTextLabel
## A [RichTextLabel] that supports custom special tag processing.
##
## The text in [member custom_text] will first be preprocessed via
## [method RichTextPreprocess.process_custom_tag]. Custom tags are in the form
## [code]#{<command>:<arg>}#[/code].


## The string to be preprocessed before being assigned to [member RichTextLabel.text].
@export_multiline var custom_text: String :
	set(v):
		custom_text = v
		_update_text()


# Used to find custom tags.
var _regex := RegEx.create_from_string(r"#\{\s*(\w+)\s*(:(.*?))?\}#")


func _ready() -> void:
	_update_text()

func _update_text() -> void:
	var processed_text := ""

	var idx := 0
	for m in _regex.search_all(custom_text):
		var command := m.get_string(1)
		var args := m.get_string(3)

		processed_text += custom_text.substr(idx, m.get_start() - idx)
		if _can_use_preprocessor():
			processed_text += RichTextPreprocess.process_custom_tag(command, args)
		else:
			processed_text += m.get_string()

		idx = m.get_end()

	processed_text += custom_text.substr(idx)

	text = processed_text

func _can_use_preprocessor() -> bool:
	return not Engine.is_editor_hint()
