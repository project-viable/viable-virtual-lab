extends Node2D
class_name ContactWire
enum {REVERSE, FORWARD, NEUTRAL}

@export var positive: bool = true
var connections = []

var point1 : Vector2
var point2 : Vector2
var width = 2
var color = Color.BLACK
var current_direction = NEUTRAL

func _ready():
	if(!positive):
		$Contact1.positive = false
		$Contact2.positive = false
		
		$Contact1._ready()
		$Contact2._ready()
		
		point1 = $Contact1.position
		point2 = $Contact2.position

func _process(delta):
	if $Contact1 and $Contact2:
		var contact1_position = $Contact1.position
		var contact2_position = $Contact2.position
		
		if point1 != contact1_position or point2 != contact2_position:
			point1 = contact1_position
			point2 = contact2_position
			update()

func _draw():
	draw_line(point1, point2, color, width)

func is_positive():
	return positive

func dispose():
	self.queue_free()
