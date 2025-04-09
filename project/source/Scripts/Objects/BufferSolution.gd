extends LabObject

# Currently the same as DummySourceContainer to use for testing

@export var substance: PackedScene = null
var contents:Node = null

func _ready() -> void:
	super()
	if substance == null:
		substance = load('res://Scenes/Objects/BufferSolutionSubstance.tscn')
	contents = substance.instantiate()

func check_contents(group: StringName) -> Array[bool]:
	return [contents.is_in_group(group)] if contents else []

func take_contents(_volume: float = -1) -> Array[Substance]:
	if substance == null:
		return []
	
	var new_content:Node = substance.instantiate()
	print("Dispensed some of TAE Buffer Solution")
	return [new_content]

func add_contents(new_contents:Array[Substance]) -> void:
	pass
