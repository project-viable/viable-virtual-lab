extends Node


func process_custom_tag(command: String, arg: String) -> String:
	match command:
		"favicon": return "[img %s]favicon.png[/img]" % [arg]
		_: return "[color=red](invalid preprocess)[/color]"
