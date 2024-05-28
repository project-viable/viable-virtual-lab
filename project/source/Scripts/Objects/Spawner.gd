extends LabObject

export (PackedScene) var objectToSpawn: PackedScene = null
export (String) var label = "New Object"
export (Vector2) var offset = Vector2(0, 0)

func _ready():
	._ready() #super()
	$Label.text = label

func TryActIndependently():
	if objectToSpawn:
		var newObject = objectToSpawn.instance()
		get_parent().add_child(newObject)
		newObject.global_position = self.global_position + offset
