class_name HintPopup
extends PreprocessedRichTextLabel


enum HintState
{
	NOT_REQUESTED, ## The hint has not been requested yet.
	QUEUED, ## The hint has been queued to be shown.
	SHOWING, ## The hint is actively being displayed on the screen.
	DISMISSED, ## The condition to hide this hint has been met while the hint was visible, so it will never again be displayed.
}


# General hints. These are mainly dismissed in `main.gd` and `main_interactable_system.gd`.
var left_right_hint := Hint.new("Press #{prompt:interact_left}# and #{prompt:interact_right}# to move left and right in the lab")
var journal_hint := Hint.new("Press #{prompt:toggle_journal}# to open the procedure")
var speed_up_time_hint := Hint.new("Hold #{prompt:speed_up_time}# to speed up time")


var _hint_queue: Array[Hint] = []
var _cur_hint: Hint = null


func _process(_delta: float) -> void:
	# Don't change the hint state until the animation has been fully played.
	if _cur_hint and _cur_hint._state != HintState.DISMISSED \
			or $AnimationPlayer.is_playing() or not $DelayTimer.is_stopped():
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
		$DelayTimer.start(_cur_hint.delay_time)
		await $DelayTimer.timeout
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

## A hint/tutorial that can be displayed in the middle of the screen via a [HintPopup], and can be
## dismissed once the user has done what it says.
class Hint:
	## Text to display in the label. This will be used as the
	## [member PreprocessedRichTextLabel.custom_text] of a [PreprocessedRichTextLabel].
	var text: String = ""
	## Time in seconds that [HintPopup] should wait before fading in this hint. During the delay,
	## no other hints can be shown. This might be used, for example, for general hints shown at
	## the very beginning of a module to give the user some time to breathe between hints.
	var delay_time: float = 0.0

	var _state := HintState.NOT_REQUESTED


	func _init(p_text: String, p_delay_time: float = 0.0) -> void:
		text = p_text
		delay_time = p_delay_time

	## Request that this hint be shown. This effectively calls
	## [code]Game.hint_popup.request_hint(self)[/code].
	func request() -> void:
		Game.hint_popup.request_hint(self)

	## If this hint is actively visible on the screen, then this function will hide it and prevent
	## it from ever being shown again. For example, if the hint says something like
	## "press [kbd]space[/kbd] to zoom in", then [method dismiss] should be called any time
	## the user zooms in with [kbd]space[/kbd].
	func dismiss() -> void:
		if is_shown(): _state = HintState.DISMISSED

	## True if this hint is actively being displayed on the screen and can be dismissed with
	## [method dismiss].
	func is_shown() -> bool:
		return _state == HintState.SHOWING
