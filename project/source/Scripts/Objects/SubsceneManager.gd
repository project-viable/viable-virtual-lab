tool
extends LabObject
class_name SubsceneManager

export(Vector2) var dimensions = Vector2(300, 300) setget SetDimensions #setget so it updates in the editor
var subsceneActive: bool
var subscene = null #We keep a reference to the subscene so we can remove it from the tree entirely when it's hidden. This is how we "pause" the subscene when it isn't active

func _ready():
	._ready() #super()
	subscene = $Subscene
	add_to_group("SubsceneManagers", true)
	subscene.z_index = VisualServer.CANVAS_ITEM_Z_MAX #to make this subscene draw above ones above it in the tree
	if not Engine.editor_hint: HideSubscene()

#Gets the depth of this subscene (ie how many ancestors it has that are also SubsceneManagers)
#This is used by main when picking which object should recieve a user action (mouse click)
func CountSubsceneDepth():
	var count = 0
	var node = self
	while node.GetSubsceneManagerParent():
		count += 1
		node = node.GetSubsceneManagerParent()
	
	return count

func SetDimensions(newDim: Vector2):
	if not subscene:
		subscene = $Subscene
	
	if newDim != dimensions: #don't always run this so that it doesn't generate new resources unless things actually change. should mean git doesn't detect changes when everything is actually the same.
		dimensions = newDim
		var newShape = RectangleShape2D.new()
		newShape.extents = Vector2(dimensions.x/2.0, dimensions.y/2.0)
		subscene.get_node("Boundary").shape = newShape
		subscene.get_node("Border").rect_position = Vector2(-dimensions.x/2.0, -dimensions.y/2.0)
		subscene.get_node("Border").rect_size = dimensions

#You can still override this function just like any other LabObject if you need different behavior.
func TryActIndependently():
	if not subsceneActive: ShowSubscene()
	return true

func ShowSubscene():
	add_child(subscene)
	subscene.owner = self
	
	AdjustSubsceneToVisibleHeight()
	
	subscene.show()
	
	subsceneActive = true

func HideSubscene():
	remove_child(subscene)
	
	subscene.hide()
	
	subsceneActive = false

func AdoptNode(node):
	var globalPos = node.global_position
	node.get_parent().remove_child(node)
	subscene.add_child(node)
	node.owner = subscene

#If our object is positioned so that the subscene would normally be partly or fully outside the area that can be visible on the screen, this function adjusts its position so that the whole thing should be visible.
func AdjustSubsceneToVisibleHeight():
	#We can't just use a VisibilityNotifier2D node because we only need to do this on y, and we need to know *how far* outside the screen it is.
	#This is taken partly from https://docs.godotengine.org/en/3.5/tutorials/2d/2d_transforms.html
	var topScreenY = (get_viewport_transform() * (get_global_transform() * Vector2(0, -(dimensions.y/2)))).y
	var bottomScreenY = (get_viewport_transform() * (get_global_transform() * Vector2(0, (dimensions.y/2)))).y
	
	#reset to no offset in case everything is ok
	subscene.position = Vector2(0, 0)
	
	#adjust to meet the bottom first, then the top, so that if they conflict the latter will be final and the close button will be visible.
	if bottomScreenY > get_viewport_rect().end.y:
		subscene.position = Vector2(0, get_viewport_rect().end.y - bottomScreenY)
	
	if topScreenY < 0:
		subscene.position = Vector2(0, -topScreenY)
