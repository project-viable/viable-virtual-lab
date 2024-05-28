extends LabObject

# Currently the same as DummySourceContainer to use for testing

export (PackedScene) var substance = null
var contents = null

func _ready():
	if substance == null:
		substance = load('res://Scenes/Objects/BufferSolutionSubstance.tscn')
	contents = substance.instance()

func CheckContents(group):
	return contents.is_in_group(group)

func TakeContents():
	if substance == null:
		return null
	
	var new_content = substance.instance()
	print("Dispensed some of TAE Buffer Solution")
	return [new_content]

func AddContents(new_contents):
	pass
