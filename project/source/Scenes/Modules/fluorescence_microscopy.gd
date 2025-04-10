extends Node2D

func _ready() -> void:
	$focus_control.focus_changed.connect(_on_focus_control_focus_changed)

func _on_computer_screen_click_signal() -> void:
	get_node("Computer/PopupControl").visible = true
	
func _on_focus_control_focus_changed(level: float) -> void:
	$Computer/PopupControl/PanelContainer/VBoxContainer/Screen/ContentScreen/CellImage/Sprite2D.material.set("shader_parameter/blur_amount", level)

func _on_microscope_mount_slide(slide: DraggableMicroscopeSlide) -> void:
	if slide and slide.slide_orientation_up:
		$Computer.current_slide = slide.slide_name
	else:
		$Computer.current_slide = ""
