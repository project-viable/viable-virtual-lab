class_name HintPopup
extends PreprocessedRichTextLabel


enum HintState
{
	NOT_REQUESTED, ## The hint has not been requested yet.
	QUEUED, ## The hint has been queued to be shown.
	SHOWING, ## The hint is actively being displayed on the screen.
	CONDITION_MET, ## The condition to hide this hint has been met, so it will never again be displayed.
}


# General hints. `is_condition_met` is set for these in `main.gd` and `main_interactable_system.gd`.
var left_right_hint := Hint.new("Press #{prompt:interact_left}# and #{prompt:interact_right}# to move left and right in the lab")
var journal_hint := Hint.new("Press #{prompt:toggle_journal}# to open the procedure")
var speed_up_time_hint := Hint.new("Hold #{prompt:speed_up_time}# to speed up time")


var _hint_queue: Array[Hint] = []
var _cur_hint: Hint = null


func _process(_delta: float) -> void:
	# Don't change the hint state until the animation has been fully played.
	if _cur_hint and _cur_hint._state != HintState.CONDITION_MET or $AnimationPlayer.is_playing():
		return

	var _prev_hint := _cur_hint
	_cur_hint = null

	if _hint_queue: _cur_hint = _hint_queue.pop_front()

	# Fade out hint before fading in new one.
	if _prev_hint:
		$AnimationPlayer.play_backwards("fade_in")
		await $AnimationPlayer.animation_finished

	if _cur_hint:
		custom_text = _cur_hint.text
		_cur_hint._state = HintState.SHOWING
		$AnimationPlayer.play("fade_in")

## Request that the hint [param hint] be shown. If [code]hint.is_condition_met[/code] is
## [code]true[/code], then the hint will not be displayed. If a hint is currently being displayed,
## then [param hint] will be placed in the back of the hint queue, to be displayed after all other
## enqueued hints have been displayed.
func request_hint(hint: Hint) -> void:
	if hint._state == HintState.NOT_REQUESTED:
		hint._state = HintState.QUEUED
		_hint_queue.push_back(hint)

## A hint to display.
class Hint:
	## Text to display in the label. This will be used as the
	## [member PreprocessedRichTextLabel.custom_text] of a [PreprocessedRichTextLabel].
	var text: String = ""

	var _state := HintState.NOT_REQUESTED


	func _init(p_text: String) -> void:
		text = p_text

	## Request that this hint be shown.
	func request() -> void:
		Game.hint_popup.request_hint(self)

	## Should be called when the condition for this hint has been met. If the hint is currently
	## displayed on-screen, then this will hide the hint. Otherwise, this will do nothing.
	func notify_condition_met() -> void:
		if _state == HintState.SHOWING:
			_state = HintState.CONDITION_MET
