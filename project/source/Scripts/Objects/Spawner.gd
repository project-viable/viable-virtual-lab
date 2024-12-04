extends LabObject

@export var objectToSpawn: PackedScene = null
@export var label: String = "New Object"
@export var offset: Vector2 = Vector2(0, 0)

func _ready() -> void:
	super()
	$Label.text = label

func TryActIndependently() -> bool:
	if objectToSpawn:
		var newObject: Node2D = objectToSpawn.instantiate()
		get_parent().add_child(newObject)
		newObject.global_position = self.global_position + offset
		return true

	return false
