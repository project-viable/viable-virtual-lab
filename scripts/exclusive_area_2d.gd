class_name ExclusiveArea2D
extends Area2D
## An area that an object can be in at most one of.
##
## An object can only be inside at most one [ExclusiveArea2D] at a time, which means that it can be
## used to do contextual physics interactions. For example, a cabinet might have an
## [ExclusiveArea2D] so that objects will only collide with its shelves when they are dropped while
## in that area.


signal object_entered_purview(object: ExclusiveObjectHitbox)
signal object_left_purview(object: ExclusiveObjectHitbox)


## When set to [code]false[/code], new objects cannot enter this area. For example, this may be set
## to [code]false[/code] for a cabinet when the door is closed.
@export var allow_new_objects: bool = true

## When set to [code]true[/code], objects can only enter this area if they first pass through a
## collision shape marked as an entry point. A collision shape is considered an entry point if it is
## in the [code]entry_point[/code] group.
##
## This should be used, for example, when making a container that can only be entered from one side.
## With this disabled, objects will start colliding with the container even if they
@export var require_entry_point_shapes: bool = false


func _ready() -> void:
	monitoring = true
	area_shape_entered.connect(_on_area_shape_entered)
	area_exited.connect(_on_area_exited)

# it is up to the [ExclusiveObjectHitbox] to call this when this becomes its exclusive area.
func object_enter_purview(object: ExclusiveObjectHitbox) -> void:
	object_entered_purview.emit(object)

func object_leave_purview(object: ExclusiveObjectHitbox) -> void:
	object_left_purview.emit(object)

func _on_area_shape_entered(_rid: RID, area: Area2D, _area_shape_index: int, local_shape_index: int) -> void:
	# Entering a different shape doesn't count as entering a second time.
	if allow_new_objects and area is ExclusiveObjectHitbox:
		var shape_owner := shape_owner_get_owner(local_shape_index) as Node
		var is_entry_shape: bool = not require_entry_point_shapes or (shape_owner and shape_owner.is_in_group(&"entry_point"))

		if is_entry_shape: area.enter_area(self)

func _on_area_exited(area: Area2D) -> void:
	# We don't need to worry about checking whether this is in the objects's stack before calling
	# `leave_area`, since `leave_area` already handles this itself.
	if area is ExclusiveObjectHitbox:
		area.leave_area(self)
