extends Node
## Provides a central access point for displaying and managing subscenes.


## All subscenes are placed with their top boundary at this coordinate.
const SUBSCENE_Y_COORD: float = 10000.0

## Any two subscenes will have at least this much space between them.
const SUBSCENE_MARGIN: float = 1000.0


# Set by the main scene. Used by [SubscenePopup]s to make their viewports look at the correct world.
# The top-level viewport is needed by the [SubscenePopup] canvas layers, since they need to 
var main_world_2d: World2D = null
var top_level_viewport: Viewport = null

var _next_x_coord: float = 0.0


## Set the [member Subscene.default_member] of the subscene [param s] to a location that will not
## overlap with any other [Subscene] nor with the main scene. This is automatically called in
## [method Subscene._enter_tree], and should not be called manually.
func allocate(s: Subscene) -> void:
	s.default_position = Vector2(_next_x_coord, SUBSCENE_Y_COORD)
	s.reset_position()
	_next_x_coord += s.size.x + SUBSCENE_MARGIN
