extends Node2D

@onready var fridge_position: Vector2 = $ClosedFridge.position
@onready var fridge_scale: Vector2 = $ClosedFridge.scale
@onready var current_fridge: StaticBody2D = $ClosedFridge
@onready var fridge_index: int = $ClosedFridge.get_index() # To preserve the order of the fridge in the node tree

func _on_computer_screen_click_signal() -> void:
	get_node("Computer/PopupControl").visible = true
	#current_fridge.visible = false #TODO: Would it be better to actually hide the fridge or just have the computer popup cover? 

func _on_fridge_on_click(is_open: bool) -> void:
	# Remove the Closed Fridge node and add the Open Fridge node
	if is_open:
		$ClosedFridge.queue_free()
		
		var opened_fridge_scene: PackedScene = preload("res://Scenes/Objects/OpenedFridge.tscn")
		var opened_fridge: StaticBody2D = opened_fridge_scene.instantiate()
		
		opened_fridge.position = fridge_position
		opened_fridge.scale = fridge_scale
		
		add_child(opened_fridge)
		move_child(opened_fridge, fridge_index) # Preserve posiiton in the node tree
		
		# Reconnect Signals
		opened_fridge.on_click.connect(_on_fridge_on_click)
		$OpenedFridge/Slides.change_slide.connect(_on_change_slides)
		
		current_fridge = opened_fridge
		
	# Remove Opened Fridge node and add the Closed Fridge node
	else:
		$OpenedFridge.queue_free()
		
		var closed_fridge_scene: PackedScene = preload("res://Scenes/Objects/ClosedFridge.tscn")
		var closed_fridge: StaticBody2D = closed_fridge_scene.instantiate()
		
		closed_fridge.position = fridge_position
		closed_fridge.scale = fridge_scale
		
		# Reconnect signals
		closed_fridge.on_click.connect(_on_fridge_on_click)
		
		add_child(closed_fridge)
		move_child(closed_fridge, fridge_index) # Preserve posiiton in the node tree
		
		current_fridge = closed_fridge


func _on_change_slides(slide: String) -> void:
	$Computer.current_slide = slide
