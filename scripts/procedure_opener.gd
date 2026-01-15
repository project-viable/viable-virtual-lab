class_name ProcedureOpener
extends Node
## Automatically sets the journal's procedure text to a given page on ready.


## Path to the journal page relative to [code]res://journal_pages/[/code].
@export var journal_page_path: String = ""
## Optional initial basic help page.
@export var initial_help_page_path: String = ""


func _ready() -> void:
	Game.journal.set_procedure_page(journal_page_path)
	if not initial_help_page_path.is_empty():
		Game.journal.go_to_page(initial_help_page_path)
