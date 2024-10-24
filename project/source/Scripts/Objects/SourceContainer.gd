@tool
extends LabObject

# This container models a substance source (like the buffer bottle) that cannot 
# be emptied of its contents, and instead dispenses creates 'content' objects 
# when something draws from it.

enum ContainerType {ERLENMEYER_FLASK, MICRO_CENTRIFUGE_TUBE} #TODO: I'm not convinced this is a good way to do this, since we have to repeatedly modify code instead of just making these, simple changes in the editor. Maybe use an inherited scene like the Pipettes
@export var containerType: ContainerType: set = SetContainerType
@export var image: Texture2D = null: set = SetOverrideImage

@export var substance: PackedScene = null
@export var substance_parameters: Array = null
var contents = null

func _ready():
	if substance == null:
		substance = load('res://Scenes/Objects/DummyLiquidSubstance.tscn')
	
	contents = substance.instantiate()
	if substance_parameters != null:
		contents.initialize(substance_parameters)
		print(str(contents.particle_sizes))
	
	SetupVisual()

func SetupVisual():
	var sprite
	var fillsprite
	
	if containerType == ContainerType.ERLENMEYER_FLASK:
			sprite = $Sprites/FlaskSprite
			fillsprite = $Sprites/FlaskFillSprite
	elif containerType == ContainerType.MICRO_CENTRIFUGE_TUBE:
			sprite = $Sprites/MicrocentrifugeTubeSprite
			fillsprite = $Sprites/MicrocentrifugeTubeFillSprite
	
	if image:
		$Sprites/CustomSprite.texture = image
		sprite = $Sprites/CustomSprite
		fillsprite = null
	
	for child in $Sprites.get_children():
		child.hide()
	
	sprite.show()
	if fillsprite:
		fillsprite.show()
		if contents: fillsprite.modulate = contents.color

func SetOverrideImage(new):
	image = new
	SetupVisual()

func SetContainerType(new):
	containerType = new
	SetupVisual()

func CheckContents(group):
	return contents.is_in_group(group)

func TakeContents(volume = -1):
	if substance == null:
		return null
	
	var new_content = substance.instantiate()
	if substance_parameters != null:
		new_content.initialize(substance_parameters)
		print(str(contents.particle_sizes))
	
	if(volume != -1):
		new_content.set_volume(volume)
	print("Dispensed some of the stored substance")
	return [new_content]

func AddContents(new_contents):
	pass
