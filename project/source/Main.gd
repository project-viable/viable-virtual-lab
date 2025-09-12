class_name Main
extends Node2D

# TODO (update): This is essentially public, so we should consider using a convention to make that
# clear, like naming it in PascalCase.
var current_module_scene: Node = null

@export var check_strategies: Array[MistakeChecker]

func check_action(params: Dictionary) -> void:
	for strategy in check_strategies:
		strategy.check_action(params)

func unload_current_module() -> void:
	LabLog.clear_logs()
	for child in $%MainScene.get_children():
		child.queue_free()

#instanciates scene and adds it as a child of $Scene. Gets rid of any scene that's already been loaded, and hides the menu.
func set_scene(scene: PackedScene) -> void:
	unload_current_module()
	var new_scene := scene.instantiate()
	$%MainScene.add_child(new_scene)
	current_module_scene = new_scene
	#$Camera.reset()

func get_deepest_subscene_at(pos: Vector2) -> Node:
	var result: Node = null

	var cast_params := PhysicsPointQueryParameters2D.new()
	cast_params.position = pos
	cast_params.collision_mask = 0b10
	cast_params.collide_with_bodies = false
	cast_params.collide_with_areas = true
	var cast_result: Array[Dictionary] = get_world_2d().direct_space_state.intersect_point(cast_params)

	if len(cast_result) > 0:
		#We found results
		for object in cast_result:
			if not object['collider'] is LabObject: #the allowed area of a subscene is not a LabObject
				if object['collider'].get_parent() is SubsceneManager: #^but its parent is the SubsceneManager
					if object['collider'].get_parent().subscene_active and (result == null or object['collider'].get_parent().count_subscene_depth() > result.count_subscene_depth()):
						result = object['collider'].get_parent()
	
	return result

func _unhandled_input(event: InputEvent) -> void:
	###Check if they clicked a LabObject first
	#check if there's any labobjects that need to deal with that input
	#Using the normal object picking (collision objects' input signals) doesn't give us the control we need
	if event.is_action_pressed("DragLabObject"):
		var cast_params := PhysicsPointQueryParameters2D.new()
		cast_params.position = get_global_mouse_position()
		cast_params.collision_mask = 0b10
		cast_params.collide_with_bodies = true
		cast_params.collide_with_areas = true
		var cast_result: Array[Dictionary] = get_world_2d().direct_space_state.intersect_point(cast_params)
		
		if len(cast_result) > 0:
			#We found results: now we need to make sure only objects in the subscene we clicked in (if any) can get this input
			var deepest_subscene := get_deepest_subscene_at(get_global_mouse_position())
			
			var pick_options: Array[LabObject] = []
			for result in cast_result:
				if result['collider'] is LabObject and (result['collider'].get_subscene_manager_parent() == deepest_subscene or (result['collider'] == deepest_subscene and not result['collider'].subscene_active)):
					pick_options.append(result['collider'])
			
			var best_pick: LabObject = null
			for object in pick_options:
				#draggables are better than non draggables, and high z indexes are tie breakers
				if best_pick == null or (
					object.draggable and not best_pick.draggable) or (
					object.z_index > best_pick.z_index and object.draggable == best_pick.draggable):
						best_pick = object
			
			if best_pick:
				if best_pick.draggable:
					best_pick.start_dragging()
				else:
					best_pick.on_user_action()
				get_viewport().set_input_as_handled()
				return
	
	#If we've made it here, then we didn't need to do something with a LabObject
	###Now see if we should do something to the camera
#	if event.is_action_pressed("DragCamera") and GameSettings.mouseCameraDrag:
#		$Camera.start_dragging()
#
#	if event.is_action_pressed("CameraZoomIn"):
#		$Camera.zoom_in()
#	if event.is_action_pressed("CameraZoomOut"):
#		$Camera.zoom_out()
