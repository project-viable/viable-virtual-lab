class_name DebugOverlay
extends GridContainer
## Manages a set of key-value pairs of debug info to display on the screen.


var _key_to_label: Dictionary[String, Label] = {}


func _input(e: InputEvent) -> void:
	if e.is_action_pressed(&"toggle_debug_overlay"):
		visible = not visible

## Update the debug string with key [param key] to display the value [param value]. If a label has
## not been created for [param key], then it will be created.
func update(key: String, value: String) -> void:
	var label: Label = _key_to_label.get(key)
	if not label:
		label = Label.new()
		label.custom_minimum_size.x = 200
		_key_to_label.set(key, label)
		add_child(label)

	label.text = "%s: %s" % [key, value]
