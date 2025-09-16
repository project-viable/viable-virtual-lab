extends UseComponent


signal volume_changed()
signal stop_changed(stop: int)


@export var volume: int = 50


## Subscene that this pipette is currently inside.
var containing_subscene: Subscene = null
## 0 is unpressed, and 2 is the second stop.
var current_stop: int = 0


var _secondary_held: bool = false
var _ternary_held: bool = false


func get_interactions(area: InteractableArea) -> Array[InteractInfo]:
	var ints: Array[InteractInfo] = []

	if not containing_subscene:
		if volume > 1:
			ints.append(InteractInfo.new(InteractInfo.Kind.ADJUST_LEFT, "Decrease volume"))
		if volume < 100:
			ints.append(InteractInfo.new(InteractInfo.Kind.ADJUST_RIGHT, "Increase volume"))
		
	if containing_subscene:
		ints.append(InteractInfo.new(InteractInfo.Kind.ZOOM, "Stop injecting"))
		var stop_desc: String = "First stop" if current_stop == 0 else "Second stop"
		if not _secondary_held:
			ints.append(InteractInfo.new(InteractInfo.Kind.SECONDARY, stop_desc))
		if not _ternary_held:
			ints.append(InteractInfo.new(InteractInfo.Kind.TERNARY, stop_desc))
	elif area is SubsceneInteractableArea and area.subscene:
		ints.append(InteractInfo.new(InteractInfo.Kind.ZOOM, "Start injecting"))
	
	return ints

func start_use(area: InteractableArea, kind: InteractInfo.Kind) -> void:
	match kind:
		InteractInfo.Kind.ADJUST_LEFT:
			volume -= 1
			volume_changed.emit()
		InteractInfo.Kind.ADJUST_RIGHT:
			volume += 1
			volume_changed.emit()
		InteractInfo.Kind.ZOOM:
			var body: CharacterBody2D = $"../Subscene/CharacterBody2D"
			if containing_subscene:
				containing_subscene = null
				Subscenes.active_subscene = null
				body.position = Vector2.ZERO 
			else:
				containing_subscene = area.subscene
				Subscenes.active_subscene = area.subscene
				body.global_position = area.subscene.get_rect().get_center() - Util.get_bounding_box(body).size * Vector2(0.5, 1)
		InteractInfo.Kind.SECONDARY:
			_secondary_held = true
			current_stop += 1
			stop_changed.emit(current_stop)
		InteractInfo.Kind.TERNARY:
			_ternary_held = true
			current_stop += 1
			stop_changed.emit(current_stop)

func stop_use(_area: InteractableArea, kind: InteractInfo.Kind) -> void:
	match kind:
		InteractInfo.Kind.SECONDARY:
			_secondary_held = false
			current_stop -= 1
			stop_changed.emit(current_stop)
		InteractInfo.Kind.TERNARY:
			_ternary_held = false
			current_stop -= 1
			stop_changed.emit(current_stop)
