class_name Journal
extends PanelContainer


const PAGE_ROOT: String = "res://journal_pages/"


@export var back_button: Button
@export var forward_button: Button
@export var journal_label: PreprocessedRichTextLabel


# Previously visited pages.
var _history: Array[HistoryEntry] = []
# Position where the next history entry will be inserted.
var _history_index: int = 0


func _ready() -> void:
	# Just a test. Remove this later.
	go_to_page("test.txt")
	_update_history_buttons()

func open() -> void:
	Game.main.set_journal_open(true)

func close() -> void:
	Game.main.set_journal_open(false)

## Attempt to load the page [param path] ,given as a path relative to [const PAGE_ROOT]. If the file
## fails to load, do nothing and return [code]false[/code]. Otherwise, go to the page, add it to
## the history stack, and return [code]true[/code].
func go_to_page(path: String) -> bool:
	if not show_page(path): return false
	_history = _history.slice(0, _history_index)
	_history.push_back(HistoryEntry.new(path))
	_history_index += 1
	_update_history_buttons()
	return true

## Attempt to display the contents of the page [param path]. If the page can't be loaded, do nothing
## and return [code]false[/code]. Otherwise, return [code]true[/code]. This function does [i]not[/i]
## affect history.
func show_page(path: String) -> bool:
	var file := FileAccess.open(PAGE_ROOT + path, FileAccess.READ)
	if not file:
		print("Failed to load journal page %s" % [path])
		return false
	journal_label.custom_text = file.get_as_text()
	return true

## Move forward or backward in history by [param n]. A negative number will move backward in
## history, and a positive number will move forward.
func move_in_history(n: int) -> void:
	if _history.is_empty(): return
	_history_index = clamp(_history_index + n, 1, _history.size())
	# We assume a page already shown in history will always work.
	show_page(_history[_history_index - 1].path)
	_update_history_buttons()

func _update_history_buttons() -> void:
	back_button.disabled = _history_index <= 1
	forward_button.disabled = _history_index >= _history.size()

func _on_back_button_pressed() -> void:
	move_in_history(-1)

func _on_forward_button_pressed() -> void:
	move_in_history(1)

func _on_preprocessed_rich_text_label_meta_clicked(meta: Variant) -> void:
	if meta is String: go_to_page(meta)


class HistoryEntry:
	# Path relative to [const PAGE_ROOT].
	var path: String


	func _init(p_path: String) -> void:
		path = p_path
