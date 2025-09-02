@tool
extends LabBody
class_name Wire #TODO: Previous simulation already uses "ContactWire". Replace this when the old simulation is removed
@export var texture: Texture2D

signal moved() # Emits whenever the contact wire is moved

var red_contact_wire: Texture2D = preload("res://updated_assets/icons_and_buttons/contact_positive.svg")
var black_contact_wire: Texture2D = preload("res://updated_assets/icons_and_buttons/contact_negative.svg")
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
