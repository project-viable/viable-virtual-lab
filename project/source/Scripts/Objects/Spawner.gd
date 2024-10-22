extends LabObject

@export var objectToSpawn: PackedScene = null
@export var label: String = "New Object"
@export var offset: Vector2 = Vector2(0, 0)

func _ready():
	super._ready() #super()
	$Label.text = label

func TryActIndependently():
	if objectToSpawn:
		var newObject = objectToSpawn.instantiate()
		get_parent().add_child(newObject)
		newObject.global_position = self.global_position + offset
