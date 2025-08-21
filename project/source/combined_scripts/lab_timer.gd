class_name LabTimer
extends Node
## Almost exactly the same as a `Timer`, but counts lab time instead of normal engine time (see
## `lab_time_singleton.gd` for details).


signal timeout()


# These are basically copied from the built-in timer code.
@export var process_callback: Timer.TimerProcessCallback = Timer.TimerProcessCallback.TIMER_PROCESS_IDLE
@export_range(0.001, 4096, 0.001, "or_greater", "exp", "suffix:s") var wait_time: float = 1.0
@export var one_shot: bool = false
@export var autostart: bool = false
@export_custom(PROPERTY_HINT_NONE, "", PROPERTY_USAGE_NONE) var paused: bool = false
@export_custom(PROPERTY_HINT_NONE, "suffix:s", PROPERTY_USAGE_NONE) var time_left: float = -1.0


var _processing: bool = false


func _ready() -> void:
	if autostart:
		start()
		autostart = false

func _process(delta: float) -> void:
	if not _processing or paused or process_callback != Timer.TimerProcessCallback.TIMER_PROCESS_IDLE:
		return

	_do_process(delta)

func _physics_process(delta: float) -> void:
	if not _processing or paused or process_callback != Timer.TimerProcessCallback.TIMER_PROCESS_PHYSICS:
		return

	_do_process(delta)

func start(time: float = -1.0) -> void:
	if time > 0.0:
		wait_time = time

	time_left = wait_time
	_processing = true

func stop() -> void:
	time_left = -1.0
	_processing = false
	autostart = false

func is_stopped() -> bool:
	return time_left <= 0.0

func _do_process(delta: float) -> void:
	time_left -= delta * LabTime.time_scale
	if time_left < 0.0:
		if not one_shot: time_left += wait_time
		else: stop()

		timeout.emit()

