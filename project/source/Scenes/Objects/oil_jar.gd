extends Area2D
var slide_entered: bool = false
var slide: DraggableMicroscopeSlide

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if slide and slide_entered:
		if not slide.is_dragging:
			slide.oiled_up = true



func _on_body_entered(body: DraggableMicroscopeSlide) -> void:
	if body is DraggableMicroscopeSlide:
		slide_entered = true
		slide = body


func _on_body_exited(body: DraggableMicroscopeSlide) -> void:
	if body is DraggableMicroscopeSlide:
		slide_entered = false
		slide = null
