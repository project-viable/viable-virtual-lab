extends Node2D


var _input_time: int = 0
var _is_microwaving: bool = false
var _total_seconds_left: int = 0
var _total_seconds: int = 0
var _is_zoomed_in: bool = false
var _is_door_open: bool = false


func _ready() -> void:
	# Connect all buttons in the keypad
	for button: TextureButton in $Keypad.get_children():
		var button_label: Label = button.get_node("Label")
		button.pressed.connect(_on_keypad_button_pressed.bind(button_label.text))
		button.mouse_filter = Control.MOUSE_FILTER_IGNORE

	_update_door()

func _input(event: InputEvent) -> void:
	if _is_zoomed_in and event.is_action_pressed("ExitCameraZoom"):
		_is_zoomed_in = false
		$ZoomArea.enable_interaction = true
		Game.camera.return_to_main_scene()

		# Buttons can't be clicked on if zoomed out.
		for button: TextureButton in $Keypad.get_children():
			button.mouse_filter = Control.MOUSE_FILTER_IGNORE

func find_container(interactor: PhysicsBody2D) -> ContainerComponent:
	# Only objects that have a `ContainerComponent` as a direct child can be microwaved. `
	var container: ContainerComponent
	for node in interactor.get_children():
		if node is ContainerComponent:
			container = node

	return container

func _on_keypad_button_pressed(button_value: String) -> void:
	match button_value:
		"Clear":
			_input_time = 0
			$TimerLabel.text = "0:00"
		"Start":
			_on_start_button_pressed()

		_:
			if str(_input_time).length() >= 4: # Keep it 4 digits max
				return

			_input_time = (_input_time * 10 + int(button_value))

			# If the user input is 300, it should be in the form 3:00
			var minutes: int = _input_time / 100
			var seconds: int = _input_time % 100

			_total_seconds_left = minutes * 60 + seconds
			_total_seconds = _total_seconds_left
			update_timer_display(minutes, seconds)

## Handles when the area is clicked on. If so zoom in on the microwave
func _on_zoom_area_pressed() -> void:
	if not _is_zoomed_in:
		_is_zoomed_in = true
		$ZoomArea.enable_interaction = false
		Game.camera.move_to_camera($ZoomCamera)

		# Keypad buttons should be clickable if zoomed in on
		for button: TextureButton in $Keypad.get_children():
			button.mouse_filter = Control.MOUSE_FILTER_STOP

## Start microwaving the object
func _on_start_button_pressed() -> void:
	if not _is_door_open:
		_is_microwaving = true
		_update_door()

		$MicrowaveTimer.start()
	else:
		$AnimationPlayer.stop()
		$AnimationPlayer.play("error_flash")

## Triggered either by the "stop" button or the timer ran out
func _on_microwave_stopped() -> void:
	if _is_microwaving:
		$MicrowaveTimer.stop()
		_is_microwaving = false
		_update_door()

		var obj: LabBody = %ObjectContainmentInteractableArea.contained_object
		if obj:
			var container_to_heat := find_container(obj)
			if container_to_heat:
				pass

		# Update _total_seconds for the next "start" press if the user doesn't clear
		_total_seconds = _total_seconds_left

func update_timer_display(minutes: int, seconds: int) -> void:
	$TimerLabel.text = "%d:%02d" % [minutes, seconds]

## Updates the TimerLabel to countdown the timer
func _on_microwave_timer_timeout() -> void:
	if _total_seconds_left > 0:
		_total_seconds_left -= 1
		_input_time -= 1
		# Convert seconds to minutes and seconds
		var minutes: int = _total_seconds_left / 60
		var seconds: int = _total_seconds_left % 60

		update_timer_display(minutes, seconds)

	else:
		$MicrowaveTimer.stop()
		_on_microwave_stopped()

func _update_door() -> void:
	if _is_door_open:
		%ObjectContainmentInteractableArea.allow_new_objects = true
		$DoorSelectable.interact_info.description = "Close door"
		%DoorOpen.show()
		%DoorClosed.hide()
	else:
		%ObjectContainmentInteractableArea.allow_new_objects = false
		$DoorSelectable.interact_info.description = "Open door"
		%DoorOpen.hide()
		%DoorClosed.show()

	$DoorSelectable.interact_info.allowed = not _is_microwaving
	if _is_microwaving:
		$DoorSelectable.interact_info.description = "Cannot open door while microwave is running"

func _on_door_selectable_pressed() -> void:
	_is_door_open = not _is_door_open
	_update_door()
