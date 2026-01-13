@tool
extends LabBody
## This class represents the contact wire object.
class_name Wire #TODO: Previous simulation already uses "ContactWire". Replace this when the old simulation is removed
## the texture to applied to objects that can be selected
@export var texture: Texture2D

## an instance that holds all wire connection logic
var connected_component: WireConnectableComponent

## Emits whenever the contact wire is moved
signal moved()

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


## Get the [WireConnectableComponent] that's attached to the other end of the wire.
func get_component_on_other_end() -> WireConnectableComponent:
	if other_end and other_end.connected_component and connected_component != other_end.connected_component:
		return other_end.connected_component

	return null
