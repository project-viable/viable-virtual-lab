extends InteractionComponent
## Microwave Interaction
@export var timer: Timer

var heatable_component: HeatableComponent
var input_time: int
var is_microwaving: bool = false
var is_object_inside: bool = false

func _process(_delta: float) -> void:
	if body == GameState.interactable:
		if not is_object_inside:
			interactable = body
			interactor = GameState.interactor
			interact(interactor)
		else:
			print("Something is already inside the microwave!")
			
		GameState.interactable = null


func interact(interactor: PhysicsBody2D) -> void:
	heatable_component = find_heatable_component(interactor)
	
	if heatable_component:
		is_object_inside = true
		interactor.set_deferred(&"freeze", true)
		interactor.set_deferred(&"position", body.position)
		interactor.set_deferred(&"visible", false)
		
	else:
		print("%s cannot be heated!" % [interactor.name])

func find_heatable_component(interactor: PhysicsBody2D) -> HeatableComponent:
	# Only objects that have the HeatableComponent can use the microwave
	var heat_component: HeatableComponent
	for node in interactor.get_children():
		if node is HeatableComponent:
			heat_component = node
	
	return heat_component


func _on_start_button_pressed() -> void:
	if is_object_inside and not is_microwaving:
		is_microwaving = true
		
		input_time = 10 # TODO: Temp placeholder, need to implement user input
		timer.wait_time = input_time
		timer.start()
		print("Heating for %s seconds!" % [input_time])
		
	elif not is_object_inside:
		print("Theres nothing in the Microwave!")
	
	elif is_microwaving:
		print("Something is currently being microwaved!")


func _on_interaction_area_area_exited(area: Area2D) -> void:
	if GameState.is_dragging and area.get_owner() == interactor: # Trigger only if that object is explicitely dragged out 
		is_object_inside = false

func _on_microwave_stopped() -> void:
	is_microwaving = false
	var time: int = timer.wait_time - timer.time_left
	heatable_component.heat(time)
	interactor.set_deferred(&"visible", true)
