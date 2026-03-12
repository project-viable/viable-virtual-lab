@tool
class_name Wire
extends LabBody


## Emits whenever the contact wire is moved
signal moved()


## the texture to applied to objects that can be selected
@export var texture: Texture2D

## The [CircuitComponent] we're plugged in to.
var connected_circuit_component: CircuitComponent

## The terminal on [member connected_component] we're connected to.
var connected_terminal_side: CircuitComponent.TerminalSide


## the previous wire postition
var prev_pos: Vector2

## an instance of the opposite end of a wire
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
