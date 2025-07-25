extends Node

var is_dragging: bool
var interactor: PhysicsBody2D # The object being dragged on top of other objects
var interactable: PhysicsBody2D # The object that is being interacted with
var target_camera: Camera2D # Used for zooming in on certain objects. We need that objects camera properties for a smooth transition
var is_camera_zoomed: bool
