@tool
class_name SevenSegmentDisplay
extends Control


## Maps characters to bits representing their segment values. If the uppercase and lowercase would
## be the same, the uppercase is preferred.
const CHAR_TO_SEGMENT_BITS: Dictionary[String, int] = {
	" ": 0b0000000,

	"0": 0b1111110,
	"1": 0b0110000,
	"2": 0b1101101,
	"3": 0b1111001,
	"4": 0b0110011,
	"5": 0b1011011,
	"6": 0b1011111,
	"7": 0b1110000,
	"8": 0b1111111,
	"9": 0b1111011,

	"A": 0b1110111,
	"b": 0b0011111,
	"C": 0b1001110,
	"c": 0b0001101,
	"d": 0b0111101,
	"E": 0b1001111,
	"F": 0b1000111,
	"H": 0b0110111,
	"h": 0b0010111,
	"J": 0b0111000,
	"L": 0b0001110,
	"n": 0b0010101,
	"o": 0b0011101,
	"P": 0b1100111,
	"r": 0b0000101,
	"t": 0b0001111,
	"U": 0b0111110,
	"u": 0b0011100,
	"y": 0b0111011,
}

const ERR_SEGMENT_BITS: int = 0b1000000


@export var segment_bits: int = 0b1111111 :
	set(v):
		segment_bits = v
		for i in 7:
			get_node(str(i)).visible = v & (1 << (6 - i)) != 0

## When set, the display will attempt to display a representation of [member character], if it is part of
## [const CHAR_TO_SEGMENT_BITS]. If this is an empty string, then it will not modify the display. If
## it is non-empty but has no representation, then it will display an error (a bar at the top).
@export var character: String = "" :
	set(v):
		character = v
		if character:
			segment_bits = CHAR_TO_SEGMENT_BITS.get(character, ERR_SEGMENT_BITS)

func _enter_tree() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func _ready() -> void:
	character = character
	segment_bits = segment_bits
