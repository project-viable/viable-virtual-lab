@abstract
class_name RegionProvider
extends Node2D
## Provides a world-space region that can be zoomed in on, for example.


## Get the current region, in world coordinates. This should return an empty [Rect2] if no region
## could be produced (this can be checked with [method Rect2.has_area]).
@abstract func get_region() -> Rect2
