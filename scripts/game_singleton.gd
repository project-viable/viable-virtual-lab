extends Node
## Provides access to nodes in the main scene. These are all set in [method Main._ready].


var main: Main
var camera: TransitionCamera
## Area around the mouse cursor used for interaction.
var cursor_area: Area2D
var debug_overlay: DebugOverlay
