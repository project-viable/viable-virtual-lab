extends Node


## Will be called with [code]null[/code] whenever something wants to close the currently displayed
## subscene.
signal subscene_activated(scene: Subscene)


const Y_POS: float = 2000.0
# Minimum distance between any adjacent subscenes.
const MARGIN: float = 1000.0


var active_subscene: Subscene = null :
	set(s):
		active_subscene = s
		subscene_activated.emit(s)


# X position of the rightmost side of the most recently allocated subscene.
var _last_x_pos: float = 0.0


## Will set the default location of the subscene [param scene] to its own location, then move it
## there via [method Subscene.reset_to_default_location].
func allocate_subscene(scene: Subscene) -> void:
	scene.default_location.x = _last_x_pos + MARGIN
	scene.default_location.y = Y_POS
	_last_x_pos += scene.size.x
	scene.reset_to_default_location()
