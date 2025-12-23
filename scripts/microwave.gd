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
			var seconds_left: int = ceil(max($MicrowaveTimer.time_left, 0))
			# Convert seconds to minutes and seconds
			var minutes: int = seconds_left / 60
			var seconds: int = seconds_left % 60

			_display_time(minutes, seconds)
		else:
			_display_time(floor(LabTime.get_hour_of_day()), floor(LabTime.get_minute_of_hour()))

func _physics_process(delta: float) -> void:
	var obj: LabBody = %ObjectContainmentInteractableArea.contained_object
	if obj and _is_microwaving():
		var container_to_heat := find_container(obj)
		if container_to_heat:
			container_to_heat.send_event(MicrowaveSubstanceEvent.new(delta * LabTime.time_scale))
		Game.report_log.update_total(snapped(((delta * LabTime.time_scale)/60), 0.01),"total_microwave_time")
		var microwave_data: String = str(container_to_heat.get_parent().name, " heated for ", Game.report_log.report_data["total_microwave_time"], " minutes")
		Game.report_log.update_event(microwave_data, "microwave_time")
		if container_to_heat.substances != null:
			for substance in container_to_heat.substances:
				if substance is TAEBufferSubstance:
					var temperature_data: String = str(container_to_heat.get_parent().name, " heated to ", int(substance.temperature) , " degrees Celsius")
					Game.report_log.update_event(temperature_data, "gel_heated_temperature")
					Game.report_log.update_total(snapped(substance.get_volume(), 0.01), "total_tae_in_gel")
					var tae_poured_data: String = str(Game.report_log.report_data["total_tae_in_gel"], " mL of TAE Buffer is in the gel")
					Game.report_log.update_event(tae_poured_data, "poured_tae_in_gel")

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
			_cancel()
		"Start":
			# If the user input is 300, it should be in the form 3:00
			var minutes: int = _input_time / 100
			var seconds: int = _input_time % 100

			var has_error := false
			if _is_door_open:
				# "door" error.
				_display_text("door")
				has_error = true
			# Zero time doesn't work and we can't properly display 99:xx if xx is greater than 60.
			elif _input_time <= 0 or minutes >= 99 and seconds >= 60:
				# "Err" generic error.
				_display_text("Err")
				has_error = true

			if has_error:
				$AnimationPlayer.stop()
				$AnimationPlayer.play("error_flash")
			else:
				$MicrowaveTimer.start(minutes * 60 + seconds)
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

			_display_time(minutes, seconds)

# Displays a time with a colon.
func _display_time(minutes: int, seconds: int) -> void:
	$Display/Colon.show()
	$Display.string = str(minutes * 100 + seconds)
	$Display.right_aligned = true

# For displaying error strings and stuff.
func _display_text(text: String) -> void:
	$Display/Colon.hide()
	$Display.string = text
	$Display.right_aligned = false

# Reset everything in the microwave.
func _cancel() -> void:
	$MicrowaveTimer.stop()
	_no_update_display = false
	_input_time = 0
	_update_door()

## Updates the Display to countdown the timer
func _on_microwave_timer_timeout() -> void:
	_display_text("End")
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

	# Opening or closing the door should reset whatever is shown on the screen, as long as we
	# aren't currently typing.
	if _input_time == 0:
		_cancel()

func _is_microwaving() -> bool:
	return not $MicrowaveTimer.is_stopped()
