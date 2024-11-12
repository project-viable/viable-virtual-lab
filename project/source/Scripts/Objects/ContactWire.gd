extends Node2D
class_name ContactWire
enum {REVERSE, FORWARD, NEUTRAL}

@export var positive: bool = true
var connections: Array[LabObject] = []

var point1: Vector2
var point2: Vector2

var width: float = 2.0
var color: Color = Color.BLACK

# TODO (update): This is an enum; we should look into whether enums can be made more statically
# typed.
var current_direction: int = NEUTRAL

func _ready() -> void:
	if(!positive):
		$Contact1.positive = false
		$Contact2.positive = false
		
		$Contact1._ready()
		$Contact2._ready()
		
		point1 = $Contact1.position
		point2 = $Contact2.position

func _process(delta: float) -> void:
	if $Contact1 and $Contact2:
		var contact1_position: Vector2 = $Contact1.position
		var contact2_position: Vector2 = $Contact2.position
		
		if point1 != contact1_position or point2 != contact2_position:
			point1 = contact1_position
			point2 = contact2_position

			queue_redraw()

func _draw() -> void:
	draw_line(point1, point2, color, width)

func is_positive() -> bool:
	return positive

func dispose() -> void:
	self.queue_free()
