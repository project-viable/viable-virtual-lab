@tool
class_name SevenSegmentDisplay
extends Control


const DIGIT_SEGMENT_BITS: Array[int] = [
	0b1111110,
	0b0110000,
	0b1101101,
	0b1111001,
	0b0110011,
	0b1011011,
	0b1011111,
	0b1110000,
	0b1111111,
	0b1111011,
]


@export var segment_bits: int = 0b1111111 :
	set(v):
		segment_bits = v
		for i in 7:
			get_node(str(i)).visible = v & (1 << (6 - i)) != 0

@export var digit: int = -1 :
	set(v):
		if v > 9 or v < 0:
			digit = -1
		else:
			digit = v
			segment_bits = DIGIT_SEGMENT_BITS[digit]


func _ready() -> void:
	segment_bits = segment_bits
