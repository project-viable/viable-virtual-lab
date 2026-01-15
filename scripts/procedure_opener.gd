class_name ProcedureOpener
extends Node
## Automatically sets the journal's procedure text to a given page on ready.


## Path to the journal page relative to [code]res://journal_pages/[/code].
@export var journal_page_path: String = ""


func _ready() -> void:
	Game.journal.set_procedure_page(journal_page_path)
