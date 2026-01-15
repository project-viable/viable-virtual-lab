class_name JournalPageOpener
extends Node
## Automatically opens a journal page when ready. This can be put in a module to open the procedure.


## Path to the journal page relative to [code]res://journal_pages/[/code].
@export var journal_page_path: String = ""


func _ready() -> void:
	Game.journal.go_to_page(journal_page_path)
