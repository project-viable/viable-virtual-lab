class_name DNAFragment
extends Resource
## Keeps track of data associated with all DNA fragments of a particular size in this solution.


@export_custom(PROPERTY_HINT_NONE, "suffix:mL") var volume: float = 0
## Position of the fragment band, relative to the length of the gel. A value of 1 is at the
## end of the gel, a value of 0 is at the start, and a negative value means the bands moved in
## the wrong direction.
@export var position: float = 0
