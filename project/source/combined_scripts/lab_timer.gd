class_name LabTimer
extends Node
## Almost exactly the same as a [Timer], but counts lab time instead of normal engine time (see
## [code]lab_time_singleton.gd[/code] for details).
##
## [LabTimer] should [i]only[/i] be used for events that take in-world time. For example, the
## running time of a microwave could use [LabTimer], but a UI popup that stays open for a certain
## amount of real-world time should use a normal [Timer] instead, since UI shouldn't be affected by
## the world being sped up.

## See [signal Timer.timeout]
signal timeout()


# These are basically copied from the built-in timer code.
## See [member Timer.process_callback].
@export_custom(PROPERTY_HINT_ENUM, "Physics,Idle") var process_callback: Timer.TimerProcessCallback = Timer.TimerProcessCallback.TIMER_PROCESS_IDLE
## See [member Timer.wait_time].
@export_range(0.001, 4096, 0.001, "or_greater", "exp", "suffix:s") var wait_time: float = 1.0
## See [member Timer.one_shot].
@export var one_shot: bool = false
## See [member Timer.autostart].
@export var autostart: bool = false
## See [member Timer.paused].
@export_custom(PROPERTY_HINT_NONE, "", PROPERTY_USAGE_NONE) var paused: bool = false
## See [member Timer.time_left].
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

## Same as [method Timer.start].
func start(time: float = -1.0) -> void:
	if time > 0.0:
		wait_time = time

	time_left = wait_time
	_processing = true

## Same as [method Timer.stop].
func stop() -> void:
	time_left = -1.0
	_processing = false
	autostart = false

## Same as [method Timer.is_stopped].
func is_stopped() -> bool:
	return time_left <= 0.0

func _do_process(delta: float) -> void:
	time_left -= delta * LabTime.time_scale
	if time_left < 0.0:
		if not one_shot: time_left += wait_time
		else: stop()

		timeout.emit()
