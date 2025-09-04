@tool
extends LabBody
class_name Wire #TODO: Previous simulation already uses "ContactWire". Replace this when the old simulation is removed
@export var texture: Texture2D

signal moved() # Emits whenever the contact wire is moved

var prev_pos: Vector2
var other_end: Wire

func _process(_delta: float) -> void:
	if not Engine.is_editor_hint():
		if position != prev_pos:
			prev_pos = position
			moved.emit()

func _ready() -> void:
	super()
	prev_pos = position
	$SelectableCanvasGroup/Sprite2D.texture = texture
