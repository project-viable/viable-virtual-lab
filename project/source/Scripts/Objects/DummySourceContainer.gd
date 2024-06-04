extends LabObject

# This container models a substance source (like the buffer bottle) that cannot 
# be emptied of its contents, and instead dispenses creates 'content' objects 
# when something draws from it.

export (PackedScene) var substance = null
export (Array) var substance_parameters = null
var contents = null
export (Texture) var image = null

# var agarose_texture = load('res://Images/ArgosePowder_Closed.png')

func _ready():
	$Sprite.texture = image
	$Sprite.scale.x *= 0.08
	$Sprite.scale.y *= 0.08
	
	$ObjectLabel.text = object_label
	if substance == null:
		substance = load('res://Scenes/Objects/DummyLiquidSubstance.tscn')
	
	contents = substance.instance()
	if substance_parameters != null:
		contents.initialize(substance_parameters)
		print(str(contents.particle_sizes))
		
func CheckContents(group):
	return contents.is_in_group(group)

func TakeContents(volume = -1):
	if substance == null:
		return null
	
	var new_content = substance.instance()
	if substance_parameters != null:
		new_content.initialize(substance_parameters)
		print(str(contents.particle_sizes))
	
	if(volume != -1):
		new_content.set_volume(volume)
	print("Dispensed some of the stored substance")
	return [new_content]

func AddContents(new_contents):
	pass
