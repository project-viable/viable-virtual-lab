extends LabObject

# Currently the same as DummySourceContainer to use for testing

@export var substance: PackedScene = null
var contents:Node = null

func _ready() -> void:
	super()
	if substance == null:
		substance = load('res://Scenes/Objects/BufferSolutionSubstance.tscn')
	contents = substance.instantiate()

func CheckContents(group:String) -> bool:
	return contents.is_in_group(group)

func TakeContents() -> Array:
	if substance == null:
		return [null]
	
	var new_content:Node = substance.instantiate()
	print("Dispensed some of TAE Buffer Solution")
	return [new_content]

func AddContents(new_contents:Array) -> void:
	pass
