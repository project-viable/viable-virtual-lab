@tool
extends RigidBody2D
class_name LabObject

#if draggable, the object can be clicked and dragged around the scene.
#when not being dragged, it will be set to whatever it's rigidbody2d mode is set to (rigid, static, etc.)
@export var draggable: bool
@export var can_change_subscenes: bool = true
@export var display_name: String = ""
@export var tooltip_display_distance: int = 35
var tooltip: Label #Set when it's created

#these variables are used internally to handle clicking and dragging:
var dragging:bool = false
var drag_offset:Vector2 = Vector2(0, 0)
var drag_start_global_pos:Vector2 = Vector2()
var max_movement_for_act_independently:int = 10 #If an object is released more than this distance fron where it started being dragged (line above), it will only interact, not act independently.
#@onready var default_mode = mode
#temporarily disabling the deafault_mode var since this changed in gd4
# trying different workarounds currently

@onready var default_z_index:int = z_index
@onready var default_z_as_relative:int = z_as_relative

var start_position:Vector2

#This variable determines whether it should call TryInteract and TryInteractIndependently
var active:bool = true

func _get_configuration_warnings() -> PackedStringArray:
	for child in get_children():
		if child is CollisionShape2D or child is CollisionPolygon2D:
			return [""]
	return ["LabObject requires at least one CollisionShape2D or CollisionPolygon2D or it can't work."]

func _enter_tree() -> void:
	self.lab_object_enter_tree()

func _exit_tree() -> void:
	self.lab_object_exit_tree()

func _ready() -> void:
	#These things happen when you create a LabObject in the editor, because it's a tool class.
	#This is just a way of overriding rigidbody's default properties to be how we need.
	add_to_group("LabObjects", true)
	collision_layer = 2 #Objects layer, no others
	collision_mask = 1 #Scene layer, no others
	can_sleep = false
	input_pickable = true
	start_position = self.position
	
	#if we're not in the editor
	if not Engine.is_editor_hint():
		#Set up the tooltip
		if len(display_name) > 1:
			var tooltip_container:Node2D = Node2D.new()
			tooltip_container.z_index = RenderingServer.CANVAS_ITEM_Z_MAX - 1
			
			tooltip = Label.new()
			tooltip.text = display_name
			tooltip.name = "labobject_auto_tooltip"
			tooltip.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
			var tooltip_stylebox:StyleBoxFlat = StyleBoxFlat.new()
			tooltip_stylebox.bg_color = Color(0.2, 0.2, 0.2, 0.8)
			tooltip.add_theme_color_override("font_color", Color(1, 1, 1))
			tooltip.add_theme_stylebox_override('normal', tooltip_stylebox)
			
			tooltip_container.add_child(tooltip)
			add_child(tooltip_container)
			tooltip.hide()
		
		#last thing
		self.lab_object_ready()

func _physics_process(delta:float) -> void:
	self.lab_object_physics_process(delta)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta:float) -> void:
	#tooltip visibility
	if tooltip:
		tooltip.visible = (GameSettings.object_tooltips and global_position.distance_squared_to(get_global_mouse_position()) < pow(tooltip_display_distance, 2))
	
	#Dragging control
	if dragging:
		#move
		if (can_change_subscenes or get_node("/root/Main").get_deepest_subscene_at(get_global_mouse_position()) == get_subscene_manager_parent()):
			drag_move()
			clamp_object_position()
		else:
			stop_dragging(false)
		
		if can_change_subscenes:
			#make sure we're in the correct subscene
			var desired_subscene:Node = get_node("/root/Main").get_deepest_subscene_at(global_position)
			if get_subscene_manager_parent() != desired_subscene:
				if desired_subscene == null:
					#we're in a subscene, but need to not be in any (null)
					var new_parent:Node = get_subscene_manager_parent().get_parent()
					var global_pos:Vector2 = global_position
					get_parent().remove_child(self)
					new_parent.add_child(self)
					owner = new_parent
					global_position = global_pos
				else:
					#go into that subscene
					desired_subscene.adopt_node(self)
		
		#see if we should continue dragging
		if Input.is_action_just_released("DragLabObject"):
			stop_dragging()
	
	#For child classes
	self.lab_object_process(delta)

#LabObject does not do this on it's own. When input happens, Main decides which if any objects should start dragging.
func start_dragging() -> void:
	dragging = true
	set_freeze_mode(RigidBody2D.FREEZE_MODE_KINEMATIC)
	# the mode behaviors changed in gd4 so "mode" doesn't really exist anymore...
	#default_mode = mode
	#mode = RigidBody2D.FREEZE_MODE_KINEMATIC
	
	default_z_index = z_index
	default_z_as_relative = z_as_relative
	z_index = RenderingServer.CANVAS_ITEM_Z_MAX - 1 #So the one being dragged is always on top of other things
	z_as_relative = true
	
	drag_offset = get_global_mouse_position() - global_position
	drag_start_global_pos = global_position

#sometimes an object needs to stop dragging without interacting (eg. when an object that can't change subscenes is dragging, and the mouse leaves its subscene)
func stop_dragging(action: bool = true) -> void:
	dragging = false
	set_linear_velocity(Vector2(0, 0))
	#mode = default_mode
	set_freeze_mode(RigidBody2D.FREEZE_MODE_STATIC)
	z_index = default_z_index
	z_as_relative = default_z_as_relative
	if action: on_user_action()

func drag_move() -> void:
	global_position = get_global_mouse_position() - drag_offset

func clamp_object_position() -> void:
	var current_module:Node = get_current_module_scene()
	var lab_boundary:Node = null
	for child in current_module.get_children():
		if child.name == "LabBoundary":
			lab_boundary = child
	if lab_boundary != null:
		global_position.x = clamp(global_position.x, lab_boundary.x_bounds[0], lab_boundary.x_bounds[1])
		global_position.y = clamp(global_position.y, lab_boundary.y_bounds[0], lab_boundary.y_bounds[1])

func get_intersecting_lab_objects() -> Array[LabObject]:
	var space_state := get_world_2d().direct_space_state
	var query_results: Array[Dictionary] = []
	
	#For each collider that we have, see if it colllides with anything.
	#This way, we could have LabObjects with multiple colliders on them (for example, multiple rectangles making up a more complex shape)
	for child in get_children():
		if child is CollisionShape2D:
			var query_options := PhysicsShapeQueryParameters2D.new()
			query_options.shape = child.shape
			query_options.transform = child.get_global_transform()
			query_options.exclude = [self]
			query_options.collision_mask = 0b10
			
			query_results.append_array(space_state.intersect_shape(query_options))
	
	var results: Array[LabObject] = []
	for other in query_results:
		#We can't use "is LabObject" here, because Godot needs to finish loading this file to know what that is. We can't compare to this script at runtime either, because that doesn't take inheritance into account.
		if other['collider'].is_in_group("LabObjects") and not other['collider'] in results:
			results.append(other['collider'])
	
	return results

#Finds the most direct SubsceneManager ancestor of this labobject.
#This is used to make sure LabObjects only interact within their subscene.
func get_subscene_manager_parent() -> Node:
	var node:Node = self
	while node.get_parent():
		#We can't use "is SubsceneManager" here, because there's a cyclic dependency.
		#This is the best way I can think of to handle this (because Godot doesn't support multiple inheritence)
		if node.get_parent().is_in_group("SubsceneManagers"):
			return node.get_parent()
		else:
			node = node.get_parent()
	
	#If we've made it here, we ran out of ancestors before finding one
	return null

func get_main() -> Node:
	return get_tree().current_scene

func get_current_module_scene() -> Node:
	return get_tree().current_scene.current_module_scene

######## Convenience Functions ########
#Use these instead of the corresponding Godot functions (like _ready()).
#Those Godot functions call them.
#You probably only need lab_object_ready() and lab_object_process(), but others are here if you need.
#These exist because we've had issues with people forgetting to call super() when they use _ready() and _process().

func lab_object_enter_tree() -> void:
	pass

func lab_object_exit_tree() -> void:
	pass

func lab_object_physics_process(delta: float) -> void:
	pass

func lab_object_process(delta: float) -> void:
	pass

func lab_object_ready() -> void:
	pass

######## Simulation Functionality Functions ########
#See the documentation for what all of these do, and when you should use each one.
#Chances are you only need try_interact() and try_act_independently()

#Called when attempting to throw away an object, can be overwritten by subclasses for specialized deletion 
func dispose() -> void:
	self.queue_free()
	
#Called automatically when this object might want to interact with others, or act on its own.
#By default, checks if this object wants to interact with others, then checks if they want to interact with it, then checks if this one wants to act alone.
#If you need different or more complex behvaior, override this.
#But you probably don't need to do that.
func on_user_action() -> void:
	if not active:
		return

	var other_lab_objects := get_intersecting_lab_objects()
	
	#now filter those results to find only the ones in the same subscene as us
	var this_lab_object_subscene := get_subscene_manager_parent()
	var interact_options: Array[LabObject] = []
	for other in other_lab_objects:
		if other.get_subscene_manager_parent() == this_lab_object_subscene:
			interact_options.append(other)
	
	####Interactions
	if interact_options:
		#First, see if we want to do something.
		var result:bool = self.try_interact(interact_options)
		
		if result:
			#We chose to interact with something, so now we need to have the module make sure that wasn't a user mistake.
			return
		else:
			#If not, see if the other objects want to do something
			for other in interact_options:
				result = other.try_interact([self])
				if result:
					#It chose to interact with us, so now we need to have the module make sure that wasn't a user mistake.
					return
	
	####Independent Actions
	if not drag_start_global_pos or not draggable or global_position.distance_to(drag_start_global_pos) <= max_movement_for_act_independently:
		var result:bool = self.try_act_independently()
		if result:
			#We chose to do something!
			return

#This should be overriden by things that extend this class.
#You should never need to call this on your own - LabObject and Main do it.
#try_interact() should decide whether to interact with each object in others, and return whether it did so.
#If others has multiple objects, this object should probably stop once it has interacted with one.
#For example, a pipette shouldn't try to interact with multiple beakers at once.
#If any decision making is required in order to do the interaction, for example:
#A pipette needs to show a menu to let the user pick what volume to get/dispense.
#try_interact() should show that menu, then when the menu is submitted, a function should be called that actually does the thing.
func try_interact(others: Array[LabObject]) -> bool:
	#The base class never interacts.
	return false

#This should be overriden by things that extend this class.
#You should never need to call this on your own - LabObject and Main do it.
#If this object needs to do anything that dooesn't depend on another object, this function should do it.
#You need to return whether you decided to do anything (true or false)
func try_act_independently() -> bool:
	#The base class doesn't do anything.
	return false

#Call this whenever you do something (like in TryInteract or TryActIndependently), so that the module code knows to check if the user made a mistake.
func report_action(objects_involved: Array, action_type: String, params: Dictionary) -> void:
	print("Reporting an action of type " + action_type + " involving " + str(objects_involved) + ". Params are " + str(params))
	
	#This function asks for these as arguments, and then manually adds them here, to remind/force you to provide them
	params['objects_involved'] = objects_involved
	params['action_type'] = action_type
	get_main().check_action(params)
	get_current_module_scene().check_action(params)

func get_start_position() -> Vector2:
	return start_position
