class_name HelpSelectableArea
extends SelectableAreaComponent
## Allows the user to press the help button to open a help page.


## Path, relative to [code]res://journal_pages/[/code], to the help page to open.
@export var help_page_path: String = ""


func _ready() -> void:
	super()
	if interact_info.kind != InteractInfo.Kind.HELP:
		interact_info = InteractInfo.new(InteractInfo.Kind.HELP, "Open help page")

func _press() -> void:
	Game.journal.go_to_page(help_page_path)
	Game.journal.open()
