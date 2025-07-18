extends InteractionComponent
## Microwave Interaction
@export var timer: Timer
@export var timer_label: Label

var heatable_component: HeatableComponent
var input_time: int = 5 # TODO: Temp placeholder, need to implement user input
var is_microwaving: bool = false
var is_object_inside: bool = false
var total_seconds_left: int = 0
var total_seconds: int = 0

func _process(_delta: float) -> void:
	if body == GameState.interactable: # Something is interacting with the Microwave
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
		
		# Change properties of the interactor
		interactor.set_deferred(&"freeze", true)
		interactor.set_deferred(&"position", body.position)
		interactor.set_deferred(&"visible", false)
		
	else:
		print("%s cannot be heated!" % [interactor.name])


## Start microwaving the object
func _on_start_button_pressed() -> void:
	if is_object_inside and not is_microwaving:
		is_microwaving = true
		
		# If the user input is 300, it should be in the form 3:00
		var minutes: int = input_time / 100
		var seconds: int = input_time % 100
		total_seconds_left = minutes * 60 + seconds
		
		total_seconds = total_seconds_left
		timer.start()
		print("Heating for %s seconds!" % [input_time])
		
	elif not is_object_inside:
		print("Theres nothing in the Microwave!")
	
	elif is_microwaving:
		print("Something is currently being microwaved!")

## Triggered either by the "stop" button or timer ran out
func _on_microwave_stopped() -> void:
	timer.stop()
	is_microwaving = false
	interactor.set_deferred(&"visible", true)
	heatable_component.heat(total_seconds - total_seconds_left)
	
	# Update input_time for the next "start" press
	input_time = total_seconds_left

## Updates the TimerLabel to countdown the timer
func _on_microwave_timer_timeout() -> void:
	if total_seconds_left > 0:
		total_seconds_left -= 1
		
		var minutes: int = total_seconds_left / 60
		var seconds: int = total_seconds_left % 60
		
		timer_label.text = "%d:%02d" % [minutes, seconds]
	
	else:
		timer.stop()
		_on_microwave_stopped()

func find_heatable_component(interactor: PhysicsBody2D) -> HeatableComponent:
	# Only objects that have the HeatableComponent can use the microwave
	var heat_component: HeatableComponent
	for node in interactor.get_children():
		if node is HeatableComponent:
			heat_component = node
	
	return heat_component
	
func _on_interaction_area_area_exited(area: Area2D) -> void:
	if GameState.is_dragging and area.get_owner() == interactor: # Trigger only if that object is explicitely dragged out 
		is_object_inside = false
