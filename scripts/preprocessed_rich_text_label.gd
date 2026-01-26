@tool
class_name PreprocessedRichTextLabel
extends RichTextLabel
## A [RichTextLabel] that supports custom special tag processing.
##
## The text in [member custom_text] will first be preprocessed via
## [method RichTextPreprocess.process_text]


## The string to be preprocessed before being assigned to [member RichTextLabel.text].
@export_multiline var custom_text: String :
	set(v):
		custom_text = v
		_update_text()


func _ready() -> void:
	_update_text()

func _update_text() -> void:
	if _can_use_preprocessor():
		text = RichTextPreprocess.process_text(custom_text)

func _can_use_preprocessor() -> bool:
	return not Engine.is_editor_hint()
