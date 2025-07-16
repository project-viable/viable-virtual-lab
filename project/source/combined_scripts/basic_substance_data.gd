## Immutable data for a basic substance. Since all instances of the same substance are the same,
## they can all point to the same instance of `BasicSubstanceData`.
class_name BasicSubstanceData
extends Resource


## This is used for display and comparison (Two 
@export var name: String = ""

## Density in g/mL.
@export var density: float = 1.0
@export var color: Color = Color.WHITE

## Melting point in °C.
@export var melting_point: float = 0.0

## Boiling point in °C.
@export var boiling_point: float = 0.0
