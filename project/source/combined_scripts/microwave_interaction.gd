extends InteractionComponent
## Microwave Interaction
@export var timer: Timer # Microwave Timer Node
@export var timer_label: Label # TimerLabel
@export var key_pad: GridContainer 
@export var key_pad_area: Area2D # If clicked on, should activate zoom
@export var camera: Camera2D

var container_to_heat: ContainerComponent
var input_time: int = 0
var is_microwaving: bool = false
var is_object_inside: bool = false
var total_seconds_left: int = 0
var total_seconds: int = 0
var is_zoomed_in: bool = false

func _ready() -> void:
	super()
	# Connect all buttons in the keypad
	for button: TextureButton in key_pad.get_children():
		var button_label: Label = button.get_node("Label")
		button.pressed.connect(_on_keypad_button_pressed.bind(button_label.text))
		button.mouse_filter = Control.MOUSE_FILTER_IGNORE
		
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
	container_to_heat = find_container(interactor)
	
	if container_to_heat:
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
		
		timer.start()
		print("Heating %s" % [interactor.name])
		
	elif not is_object_inside:
		print("Theres nothing in the Microwave!")
	
	elif is_microwaving:
		print("Something is currently being microwaved!")

## Triggered either by the "stop" button or the timer ran out
func _on_microwave_stopped() -> void:
	if is_microwaving:
		timer.stop()
		is_microwaving = false
		interactor.set_deferred(&"visible", true)
		is_object_inside = false

		# TODO: This calculation should be handled by the `ContainerComponent` and substances
		# themselves.
		#
		# This is very approximately equal to the amount of heating you would get if the container
		# were full of only water.
		var temp_increase: float = 160.0 * (total_seconds - total_seconds_left) \
			/ container_to_heat.get_total_volume()
		container_to_heat.temperature += temp_increase
		
		# Update total_seconds for the next "start" press if the user doesn't clear
		total_seconds = total_seconds_left

## Updates the TimerLabel to countdown the timer
func _on_microwave_timer_timeout() -> void:
	if total_seconds_left > 0:
		total_seconds_left -= 1
		input_time -= 1
		# Convert seconds to minutes and seconds
		var minutes: int = total_seconds_left / 60
		var seconds: int = total_seconds_left % 60
		
		update_timer_display(minutes, seconds)
	
	else:
		timer.stop()
		_on_microwave_stopped()

func find_container(interactor: PhysicsBody2D) -> ContainerComponent:
	# Only objects that have a `ContainerComponent` as a direct child can be microwaved. `
	var container: ContainerComponent
	for node in interactor.get_children():
		if node is ContainerComponent:
			container = node
	
	return container
	
func _on_interaction_area_area_exited(area: Area2D) -> void:
	if GameState.is_dragging and area.get_owner() == interactor: # Trigger only if that object is explicitely dragged out 
		is_object_inside = false
		
func _on_keypad_button_pressed(button_value: String) -> void:
	match button_value:
		"Clear":
			input_time = 0
			timer_label.text = "0:00"
		"Start":
			_on_start_button_pressed()
			
		_:
			if str(input_time).length() >= 4: # Keep it 4 digits max
				return
				
			input_time = (input_time * 10 + int(button_value))  
			
			# If the user input is 300, it should be in the form 3:00
			var minutes: int = input_time / 100
			var seconds: int = input_time % 100
			
			total_seconds_left = minutes * 60 + seconds
			total_seconds = total_seconds_left
			update_timer_display(minutes, seconds)
			
			

func update_timer_display(minutes: int, seconds: int) -> void:
	timer_label.text = "%d:%02d" % [minutes, seconds]


func _input(event: InputEvent) -> void:
	if is_zoomed_in and event.is_action_pressed("ExitCameraZoom"):
		is_zoomed_in = false
		
		# Buttons can't be clicked on if zoomed out. 
		for button: TextureButton in key_pad.get_children():
			button.mouse_filter = Control.MOUSE_FILTER_IGNORE

## Handles when the area is clicked on. If so zoom in on the microwave
func _on_keypad_area_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event.is_action_pressed("click") and not is_zoomed_in:
		is_zoomed_in = true
		GameState.target_camera = camera
		
		# Keypad buttons should be clickable if zoomed in on
		for button: TextureButton in key_pad.get_children():
			button.mouse_filter = Control.MOUSE_FILTER_STOP
