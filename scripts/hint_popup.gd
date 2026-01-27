class_name HintPopup
extends PreprocessedRichTextLabel


# General hints. `is_condition_met` is set for these in `main.gd` and `main_interactable_system.gd`.
var left_right_hint := Hint.new("Press #{prompt:interact_left}# and #{prompt:interact_right}# to move left and right in the lab")
var journal_hint := Hint.new("Press #{prompt:toggle_journal}# to open the procedure")
var speed_up_time_hint := Hint.new("Hold #{prompt:speed_up_time}# to speed up time")


var _hint_queue: Array[Hint] = []
var _cur_hint: Hint = null


func _process(_delta: float) -> void:
	if _cur_hint and not _cur_hint.is_condition_met: return

	_cur_hint = null

	# Clear hints whose conditions have been met already.
	var next_hint_index := _hint_queue.find_custom(func(h: Hint) -> bool: return not h.is_condition_met)
	if next_hint_index >= 0:
		_hint_queue.assign(_hint_queue.slice(next_hint_index))

	if _hint_queue: _cur_hint = _hint_queue.pop_front()


	if _cur_hint:
		custom_text = _cur_hint.text
		show()
	else:
		hide()

## Request that the hint [param hint] be shown. If [code]hint.is_condition_met[/code] is
## [code]true[/code], then the hint will not be displayed. If a hint is currently being displayed,
## then [param hint] will be placed in the back of the hint queue, to be displayed after all other
## enqueued hints have been displayed.
func request_hint(hint: Hint) -> void:
	if not hint.is_condition_met: _hint_queue.push_back(hint)


## A hint to display.
class Hint:
	## Text to display in the label. This will be used as the
	## [member PreprocessedRichTextLabel.custom_text] of a [PreprocessedRichTextLabel].
	var text: String = ""
	## If set to [code]true[/code], this will no longer be displayed.
	var is_condition_met: bool = false


	func _init(p_text: String) -> void:
		text = p_text
