@tool
extends LabObject
class_name SubsceneManager

@export var dimensions: Vector2 = Vector2(300, 300): set = SetDimensions
var subscene_active: bool
var subscene: Area2D = null #We keep a reference to the subscene so we can remove it from the tree entirely when it's hidden. This is how we "pause" the subscene when it isn't active

func _ready() -> void:
	super._ready() #super()

	subscene = $Subscene
	add_to_group("SubsceneManagers", true)
	subscene.z_index = RenderingServer.CANVAS_ITEM_Z_MAX #to make this subscene draw above ones above it in the tree
	if not Engine.is_editor_hint(): HideSubscene()

#Gets the depth of this subscene (ie how many ancestors it has that are also SubsceneManagers)
#This is used by main when picking which object should recieve a user action (mouse click)
func CountSubsceneDepth() -> int:
	var count: int = 0
	var node: SubsceneManager = self
	while node.GetSubsceneManagerParent():
		count += 1
		node = node.GetSubsceneManagerParent()
	
	return count

func SetDimensions(new_dim: Vector2) -> void:
	if not subscene:
		subscene = $Subscene
	
	if new_dim != dimensions: #don't always run this so that it doesn't generate new resources unless things actually change. should mean git doesn't detect changes when everything is actually the same.
		dimensions = new_dim
		var new_shape: RectangleShape2D = RectangleShape2D.new()
		new_shape.extents = Vector2(dimensions.x/2.0, dimensions.y/2.0)
		subscene.get_node("Boundary").shape = new_shape
		subscene.get_node("Border").position = Vector2(-dimensions.x/2.0, -dimensions.y/2.0)
		subscene.get_node("Border").size = dimensions

#You can still override this function just like any other LabObject if you need different behavior.
func TryActIndependently() -> bool:
	if not subscene_active: ShowSubscene()
	return true

func ShowSubscene() -> void:
	add_child(subscene)
	subscene.owner = self
	
	AdjustSubsceneToVisibleHeight()
	
	subscene.show()
	
	subscene_active = true

func HideSubscene() -> void:
	if subscene in self.get_children():
		remove_child(subscene)
	
	subscene.hide()
	
	subscene_active = false

func AdoptNode(node) -> void:
	var global_pos: Vector2 = node.global_position
	node.get_parent().remove_child(node)
	subscene.add_child(node)
	node.owner = subscene

#If our object is positioned so that the subscene would normally be partly or fully outside the area that can be visible on the screen, this function adjusts its position so that the whole thing should be visible.
func AdjustSubsceneToVisibleHeight() -> void:
	#We can't just use a VisibilityNotifier2D node because we only need to do this on y, and we need to know *how far* outside the screen it is.
	#This is taken partly from https://docs.godotengine.org/en/3.5/tutorials/2d/2d_transforms.html
	var top_screen_y = (get_viewport_transform() * (get_global_transform() * Vector2(0, -(dimensions.y/2)))).y
	var bottom_screen_y = (get_viewport_transform() * (get_global_transform() * Vector2(0, (dimensions.y/2)))).y
	
	#reset to no offset in case everything is ok
	subscene.position = Vector2(0, 0)
	
	#adjust to meet the bottom first, then the top, so that if they conflict the latter will be final and the close button will be visible.
	if bottom_screen_y > get_viewport_rect().end.y:
		subscene.position = Vector2(0, get_viewport_rect().end.y - bottom_screen_y)
	
	if top_screen_y < 0:
		subscene.position = Vector2(0, -top_screen_y)
