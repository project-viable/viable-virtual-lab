extends LabObject

@export var object_to_spawn: PackedScene = null
@export var label: String = "New Object"
@export var offset: Vector2 = Vector2(0, 0)

func _ready() -> void:
	super()
	$Label.text = label

func try_act_independently() -> bool:
	if object_to_spawn:
		var new_object: Node2D = object_to_spawn.instantiate()
		get_parent().add_child(new_object)
		new_object.global_position = self.global_position + offset
		return true

	return false
