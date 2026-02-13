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


var _context := RichTextPreprocess.Context.new()


func _notification(what: int) -> void:
	if what == NOTIFICATION_THEME_CHANGED:
		_update_text()

func _ready() -> void:
	_update_text()

func _update_text() -> void:
	_context.base_font_size = get_theme_font_size("normal_font_size")
	text = RichTextPreprocess.process_text(custom_text, _context)
