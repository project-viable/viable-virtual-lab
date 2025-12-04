extends Node2D


var _no_update_display: bool = false
var _input_time: int = 0
var _is_door_open: bool = false


func _ready() -> void:
	# Connect all buttons in the keypad
	for button: TextureButton in $Keypad.get_children():
		var button_label: Label = button.get_node("Label")
		button.pressed.connect(_on_keypad_button_pressed.bind(button_label.text))
		button.mouse_filter = Control.MOUSE_FILTER_IGNORE

	_update_door()

func _process(_delta: float) -> void:
	if not _no_update_display:
		if _is_microwaving():
			var seconds_left := int(max($MicrowaveTimer.time_left, 0))
			# Convert seconds to minutes and seconds
			var minutes: int = seconds_left / 60
			var seconds: int = seconds_left % 60

			update_timer_display(minutes, seconds)
		else:
			update_timer_display(floor(LabTime.get_hour_of_day()), floor(LabTime.get_minute_of_hour()))

func _physics_process(delta: float) -> void:
	var obj: LabBody = %ObjectContainmentInteractableArea.contained_object
	if obj and _is_microwaving():
		var container_to_heat := find_container(obj)
		if container_to_heat:
			for s in container_to_heat.substances:
				# TODO: Make this not hard-coded.
				if s is TAEBufferSubstance:
					s.microwave(delta * LabTime.time_scale)

func find_container(interactor: PhysicsBody2D) -> ContainerComponent:
	# Only objects that have a `ContainerComponent` as a direct child can be microwaved. `
	var container: ContainerComponent
	for node in interactor.get_children():
		if node is ContainerComponent:
			container = node

	return container

func _on_keypad_button_pressed(button_value: String) -> void:
	match button_value:
		"Cancel":
			$MicrowaveTimer.stop()
			_no_update_display = false
			_input_time = 0
			_update_door()
		"Start":
			if not _is_door_open and _input_time > 0:
				# If the user input is 300, it should be in the form 3:00
				var minutes: int = _input_time / 100
				var seconds: int = _input_time % 100
				$MicrowaveTimer.start(minutes * 60 + seconds)

			else:
				$AnimationPlayer.stop()
				$AnimationPlayer.play("error_flash")

			_no_update_display = false
			_input_time = 0

			_update_door()
		_:
			_no_update_display = true

			if str(_input_time).length() >= 4: # Keep it 4 digits max
				return

			_input_time = (_input_time * 10 + int(button_value))

			# If the user input is 300, it should be in the form 3:00
			var minutes: int = _input_time / 100
			var seconds: int = _input_time % 100

			update_timer_display(minutes, seconds)

func update_timer_display(minutes: int, seconds: int) -> void:
	$TimerLabel.text = "%d:%02d" % [minutes, seconds]

## Updates the TimerLabel to countdown the timer
func _on_microwave_timer_timeout() -> void:
	$TimerLabel.text = "End"
	_no_update_display = true
	_update_door()

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

	$DoorSelectable.interact_info.allowed = not _is_microwaving()
	if _is_microwaving():
		$DoorSelectable.interact_info.description = "Cannot open door while microwave is running"

func _on_door_selectable_pressed() -> void:
	_is_door_open = not _is_door_open
	_update_door()

	# Remove the "End" when opening the door.
	if _is_door_open and _input_time == 0:
		_no_update_display = false

func _on_zoom_selectable_area_zoomed_in() -> void:
	# Keypad buttons should be clickable if zoomed in on
	for button: TextureButton in $Keypad.get_children():
		button.mouse_filter = Control.MOUSE_FILTER_STOP

func _on_zoom_selectable_area_zoomed_out() -> void:
	for button: TextureButton in $Keypad.get_children():
		button.mouse_filter = Control.MOUSE_FILTER_IGNORE

func _is_microwaving() -> bool:
	return not $MicrowaveTimer.is_stopped()
