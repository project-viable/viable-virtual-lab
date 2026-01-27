class_name Main
extends Node2D


const INTERACTION_PROMPT_SCENE := preload("res://scenes/interaction_prompt.tscn")
const TIME_WARP_ADJUST_SPEED := 10.0
# Amount of time the "speed up time" button must be held to dismiss a hint.
const SPEED_UP_TIME_HOLD_HINT_DURATION := 0.5


## This will be called with [code]null[/code] when returning to the workspace.
signal camera_focus_owner_changed(focus_owner: Node)


@export var all_modules: Array[ModuleData]


var _resolution_options: Array[Vector2i] = [
	Vector2i(1280, 720),
	Vector2i(1366, 768),
	Vector2i(1600, 900),
	Vector2i(1920, 1080),
	Vector2i(2560, 1440),
	Vector2i(3200, 1800),
	Vector2i(3840, 2160),
]

var _current_module_scene: Node = null
var _module_button: PackedScene = load("res://scenes/module_select_button.tscn")
var _current_module: ModuleData = null
var _current_workspace: WorkspaceCamera = null
var _camera_focus_owner: Node = null
var _interact_kind_prompts: Dictionary[InteractInfo.Kind, InteractionPrompt] = {}
var _time_warp_strength: float = 0
# Time the "speed up time" button has been held down.
var _speed_up_time_time_held := 0.0
var _is_speed_up_time_held := false

@onready var _hand_pointing_cursor: Sprite2D = $%VirtualCursor/HandPointing
@onready var _hand_open_cursor: Sprite2D = $%VirtualCursor/HandOpen
@onready var _hand_closed_cursor: Sprite2D = $%VirtualCursor/HandClosed
@onready var _cursor_collision: CollisionShape2D = $SceneLayer/ContentScaledSubViewportContainer/MainViewport/CursorArea/CollisionShape2D
@onready var _cursor_collision_original_size: Vector2 = _cursor_collision.shape.size
@onready var _cursor_collision_original_pos: Vector2 = _cursor_collision.position


func _enter_tree() -> void:
	# These need to be set in `_enter_tree` instead of `_ready` so that we can be pretty sure they
	# are set before any `SubscenePopup` is ready.
	Subscenes.main_world_2d = $%MainViewport.get_world_2d()
	Subscenes.top_level_viewport = get_viewport()

	# Change pause key on the browser version.
	if _is_in_web_browser():
		# Backtick key.
		var input_event := InputEventKey.new()
		input_event.physical_keycode = KEY_QUOTELEFT

		InputMap.action_erase_events(&"toggle_menu")
		InputMap.action_add_event(&"toggle_menu", input_event)

func _ready() -> void:
	Game.main = self
	Game.camera = $%TransitionCamera
	Game.cursor_area = $%CursorArea
	Game.debug_overlay = $%DebugOverlay
	Game.report_log = $%GelLogReport
	Game.journal = %Journal
	Game.hint_popup = %HintPopup

	$%SubsceneViewport.world_2d = Subscenes.main_world_2d

	_switch_to_main_menu()
	set_pause_menu_open(true)

	#Set up the module select buttons
	for module_data in all_modules:
		if module_data.show:
			var new_button := _module_button.instantiate()
			new_button.set_data(module_data)
			new_button.connect("pressed", Callable(self, &"_load_module").bind(module_data))
			$%Modules.add_child(new_button)

	Cursor.mode_changed.connect(_on_virtual_mouse_mode_changed)
	Cursor.virtual_mouse_moved.connect(_on_virtual_mouse_moved)
	%TransitionCamera.moved.connect(_update_virtual_mouse)

	# The subviewport needs to match the window size.
	get_window().size_changed.connect(_update_viewport_to_window_size)

	# The quit button is meaningless in a browser.
	if _is_in_web_browser():
		%MenuScreenManager/PauseMenu/Content/QuitButton.hide()

	# Only give resolution options if we can actually set the size. Otherwise, don't touch the
	# resolution options.
	if _can_resize_os_window():
		get_window().unresizable = true

		var max_resolution := DisplayServer.screen_get_usable_rect().size

		var idx := 0
		var saved_resolution_index := 0
		var first := true

		# Show relevant resolution options.
		for r in _resolution_options:
			# We always include the first resolution in the list even if it's too big to make sure we
			# have one.
			if first or r.x <= max_resolution.x and r.y <= max_resolution.y:
				$%ResolutionDropdown.add_item("%s × %s" % [r.x, r.y])
				$%ResolutionDropdown.set_item_metadata(idx, r)
				if GameSettings.resolution == r:
					saved_resolution_index = idx
				first = false

			idx += 1

		# Set the resolution to the one matching the config. If the config resolution doesn't match
		# any of the available ones, then it will automatically choose the first option.
		$%ResolutionDropdown.select(saved_resolution_index)
		_on_resolution_dropdown_item_selected(saved_resolution_index)
	else:
		print("Not running in standalone window; disabling resizing.")
		$%ResolutionDropdown.add_item("cannot resize")
		_update_viewport_to_window_size()

	# Update UI elements for settings.
	%MouseSensitivitySlider.set_value_no_signal(GameSettings.mouse_sensitivity)

	# The zoom prompt is at the top always.
	_interact_kind_prompts[InteractInfo.Kind.INSPECT] = %ZoomOutPrompt

	for kind: InteractInfo.Kind in InteractInfo.Kind.values():
		# Don't make a new prompt for one already set previously (like the inspect prompt at the top
		# of the screen.
		if _interact_kind_prompts.has(kind): continue

		var prompt: InteractionPrompt = INTERACTION_PROMPT_SCENE.instantiate()
		var action_event := InputEventAction.new()
		action_event.action = InteractInfo.kind_to_action(kind)
		prompt.input_event = action_event
		%Prompts/InteractPrompts.add_child(prompt)

		_interact_kind_prompts[kind] = prompt

func _process(delta: float) -> void:
	for prompt: InteractionPrompt in _interact_kind_prompts.values():
		prompt.hide()

	# Don't show prompts in the main menu.
	if _current_module_scene:
		for kind: InteractInfo.Kind in InteractInfo.Kind.values():
			var prompt: InteractionPrompt = _interact_kind_prompts.get(kind)
			if not prompt: continue

			var state: Interaction.InteractState = Interaction.interactions.get(kind)
			if state.info and state.info.show_prompt:
				prompt.show()
				prompt.disabled = not state.info.allowed
				prompt.description = state.info.description
				prompt.pressed = state.is_pressed

	Game.debug_overlay.update("FPS", str(Engine.get_frames_per_second()))

	%LeftWorkspacePrompt.visible = _current_workspace and not _camera_focus_owner
	%LeftWorkspacePrompt.disabled = _current_workspace and not _current_workspace.left_workspace
	%RightWorkspacePrompt.visible = _current_workspace and not _camera_focus_owner
	%RightWorkspacePrompt.disabled = _current_workspace and not _current_workspace.right_workspace

	# Same as the wall clock code.
	if _is_speed_up_time_held:
		_speed_up_time_time_held += delta
		LabTime.time_scale = ease(_speed_up_time_time_held / 3.0, 2.0) * 100.0 + 1.0

		if _speed_up_time_time_held >= SPEED_UP_TIME_HOLD_HINT_DURATION:
			Game.hint_popup.speed_up_time_hint.dismiss()

	var target_time_warp_strength := (LabTime.time_scale - 1) / 20
	if target_time_warp_strength > _time_warp_strength:
		_time_warp_strength = min(target_time_warp_strength, _time_warp_strength + TIME_WARP_ADJUST_SPEED * delta)
	else:
		_time_warp_strength = max(target_time_warp_strength, _time_warp_strength - TIME_WARP_ADJUST_SPEED * delta)

	# Time warp shader.
	%Postprocess/TimeWarp/Rect.material.set(&"shader_parameter/strength", _time_warp_strength)

func _unhandled_key_input(e: InputEvent) -> void:
	if e.is_action_pressed(&"toggle_menu"):
		# Close the journal if it's open.
		if is_journal_open():
			set_journal_open(false)
		# A page other than the main pause menu is being shown; return to the pause menu.
		elif is_pause_menu_open() and not %MenuScreenManager.is_on_primary_screen():
			%MenuScreenManager.pop_screen()
		# Toggle the pause menu only if we're in a module.
		elif _current_module_scene != null:
			set_pause_menu_open(not is_pause_menu_open())
	elif e.is_action_pressed(&"toggle_journal"):
		# Toggling it while in the pause menu would be weird.
		if not is_pause_menu_open():
			# Dismiss "press J to open the procedure" hint if this is pressed to *open* the
			# journal. We know it will be opened if it's closed here.
			if not is_journal_open():
				Game.hint_popup.journal_hint.dismiss()

			set_journal_open(not is_journal_open())
	elif e.is_action_pressed(&"speed_up_time"):
		_speed_up_time_time_held = 0.0
		_is_speed_up_time_held = true
	elif e.is_action_released(&"speed_up_time"):
		_is_speed_up_time_held = false
		LabTime.time_scale = 1.0

func _load_module(module: ModuleData) -> void:
	set_scene(load(module.scene_path))

	%MenuScreenManager.pop_all_screens()
	$UILayer/Background.hide()
	%MenuScreenManager/PauseMenu/Content/Logo.hide()
	%MenuScreenManager/PauseMenu/Content/ExitModuleButton.show()
	%MenuScreenManager/PauseMenu/Content/RestartModuleButton.show()

	_current_module = module

	%Prompts.show()

	_update_scene_overlays()

	# To make the initial virtual mouse position feel less weird.
	Cursor.virtual_mouse_position = get_global_mouse_position()
	set_pause_menu_open(false)

func unload_current_module() -> void:
	Interaction.clear_all_interaction_state()
	DepthManager.clear_layers()
	Game.journal.clear()
	hide_subscene()
	move_to_workspace(null)
	_current_module_scene = null
	for child in $%Scene.get_children():
		child.queue_free()

#instanciates scene and adds it as a child of %$Scene. Gets rid of any scene that's already been loaded, and hides the menu.
func set_scene(scene: PackedScene) -> void:
	unload_current_module()
	var new_scene := scene.instantiate()
	$%Scene.call_deferred("add_child", new_scene)
	_current_module_scene = new_scene
	#$Camera.reset()

# Sets whether the pause menu is shown and the game is paused.
func set_pause_menu_open(paused: bool) -> void:
	%MenuScreenManager.visible = paused
	_update_simulation_pause()
	_update_scene_overlays()

func is_pause_menu_open() -> bool:
	return %MenuScreenManager.visible

func set_journal_open(open: bool) -> void:
	%Journal.visible = open
	if %Journal.visible:
		Game.report_log.load_report_data()
	else:
		Game.report_log.rich_text_label.clear()
	_update_simulation_pause()
	_update_scene_overlays()

func is_journal_open() -> bool:
	return %Journal.visible

## Move the camera to workspace [param workspace] in time [param time].
func move_to_workspace(workspace: WorkspaceCamera, time: float = 0.0) -> void:
	_current_workspace = workspace
	if _current_workspace:
		$%TransitionCamera.move_to_camera(workspace, true, time)
	set_camera_focus_owner(null)

func return_to_current_workspace() -> void:
	hide_subscene()
	if _current_workspace:
		$%TransitionCamera.move_to_camera(_current_workspace, false)
		set_camera_focus_owner(null)

## Move the camera to frame [param rect] in the center of the screen.
func focus_camera_on_rect(rect: Rect2, time: float = 0.7) -> void:
	var dest_rect := Util.expand_to_aspect(rect.grow(10), get_viewport_rect().size.aspect())
	$%TransitionCamera.move_to_rect(dest_rect, false, time)

## Set the "camera focus owner". The [param focus_owner] node isn't actually used for anything, but
## acts as a marker to allow a node know whether it is zoomed in and to tell main whether to show
## the "zoom out" prompt. This should generally be called after zooming in the camera.
##
## If a node wants to do something special when the camera is zoomed out, it can connect to
## [signal camera_focus_owner_changed] to detect that (since it's called with [code]null[/code]
## whenever [method return_to_current_workspace] is called).
func set_camera_focus_owner(focus_owner: Node) -> void:
	$InteractableSystem.can_zoom_out = (focus_owner != null)
	_camera_focus_owner = focus_owner
	camera_focus_owner_changed.emit(_camera_focus_owner)

## Use this to determine whether the screen in "zoomed out".
func get_camera_focus_owner() -> Node:
	return _camera_focus_owner

## Makes the view of the subscene camera [param camera] visible on the right side of the screen.
## Returns the width, in pixels, of the open region on the left side of the screen (this can be
## used, for example, to use the left side to zoom in on something). If [param use_overlay] is
## [code]true[/code], then a dark overlay will be placed over the screen behind the subscene. This
## should be used to indicate when control has moved to the subscene, like when the pipette subscene
## becomes controllable.
func show_subscene(camera: SubsceneCamera) -> float:
	var viewport_size := get_viewport_rect().size
	var right_width: float = max(viewport_size.x / 2, camera.region_size.x + 50)
	var padding: float = (right_width - camera.region_size.x) / 2
	camera.custom_viewport = $%SubsceneViewport
	$%SubsceneContainer.size = camera.region_size
	$%SubsceneContainer.position.x = viewport_size.x - right_width + padding
	$%SubsceneContainer.position.y = (viewport_size.y - $%SubsceneContainer.size.y) / 2
	$%SubsceneContainer.show()
	camera.make_current()
	_update_scene_overlays()
	return viewport_size.x - right_width

func hide_subscene() -> void:
	$%SubsceneContainer.hide()
	_update_scene_overlays()

## Show the subscene camera [param camera] on the right side of the screen and use the left side of
## the screen to zoom in on the rectangle [param rect], similarly to [method focus_camera_on_rect].
func focus_camera_and_show_subscene(rect: Rect2, camera: SubsceneCamera, time: float = 0.7) -> void:
	var viewport_size := get_viewport().get_visible_rect().size
	var left_width := show_subscene(camera)
	var left_aspect := Vector2(left_width, viewport_size.y).aspect()
	var left_rect := Util.expand_to_aspect(rect.grow(10), left_aspect)
	var full_rect := Util.expand_to_aspect(left_rect, viewport_size.aspect(), 0)
	$%TransitionCamera.move_to_rect(full_rect, false, time)

func _on_exit_module_button_pressed() -> void:
	_switch_to_main_menu()

func _switch_to_main_menu() -> void:
	unload_current_module()

	set_journal_open(false)
	set_pause_menu_open(true)

	%MenuScreenManager.pop_all_screens()
	%MenuScreenManager/PauseMenu/Content/Logo.show()
	%MenuScreenManager/PauseMenu/Content/ExitModuleButton.hide()
	%MenuScreenManager/PauseMenu/Content/RestartModuleButton.hide()
	$UILayer/Background.show()

	%Prompts.hide()

	_update_scene_overlays()

func _on_quit_button_pressed() -> void:
	get_tree().quit()

func _on_restart_module_button_pressed() -> void:
	_load_module(_current_module)

func _on_resolution_dropdown_item_selected(index: int) -> void:
	var resolution: Variant = $%ResolutionDropdown.get_item_metadata(index)
	if resolution is Vector2i:
		GameSettings.resolution = resolution
		_try_resize_os_window(resolution)
	else:
		push_warning("Tried to set invalid resolution %s" % [resolution])

func _can_resize_os_window() -> bool:
	return not get_window().is_embedded() and not Engine.is_embedded_in_editor() and not _is_in_web_browser()

# Attempt to resize the OS window. If we can't directly set the OS window (for example, because
# it's embedded), then do nothing.
func _try_resize_os_window(size: Vector2i) -> void:
	if _can_resize_os_window():
		get_window().size = size
		get_window().move_to_center()

func _is_in_web_browser() -> bool:
	return OS.has_feature("web")

func _update_viewport_to_window_size() -> void:
	$%MainViewport.size = get_window().size

func _on_cursor_area_body_entered(body: Node2D) -> void:
	if body is LabBody: body.is_moused_over = true

func _on_cursor_area_body_exited(body: Node2D) -> void:
	if body is LabBody: body.is_moused_over = false

func _on_interactable_system_pressed_left() -> void:
	if _current_workspace and _current_workspace.left_workspace and not _camera_focus_owner:
		move_to_workspace(_current_workspace.left_workspace, 1.0)

func _on_interactable_system_pressed_right() -> void:
	if _current_workspace and _current_workspace.right_workspace and not _camera_focus_owner:
		move_to_workspace(_current_workspace.right_workspace, 1.0)

func _on_interactable_system_pressed_zoom_out() -> void:
	if _camera_focus_owner: return_to_current_workspace()

func _on_virtual_mouse_moved(_old: Vector2, _new: Vector2) -> void:
	_update_virtual_mouse();

func _on_virtual_mouse_mode_changed(_mode: Cursor.Mode) -> void:
	_update_virtual_mouse();

func _update_virtual_mouse() -> void:
	# The coordinate system for the main viewport and the cursor canvas layer are different, so
	# we have to convert.
	var main_to_cursor_canvas: Transform2D = $UILayer.get_final_transform().affine_inverse() * $%MainViewport.canvas_transform
	var cursor_canvas_mouse_pos := main_to_cursor_canvas * Cursor.virtual_mouse_position

	for c in $%VirtualCursor.get_children():
		c.hide()
	var cursor_to_use: Sprite2D = _hand_pointing_cursor
	match Cursor.mode:
		Cursor.Mode.OPEN: cursor_to_use = _hand_open_cursor
		Cursor.Mode.CLOSED: cursor_to_use = _hand_closed_cursor
	cursor_to_use.show()

	$%VirtualCursor.global_position = cursor_canvas_mouse_pos
	# We have to call `$%CursorArea.get_global_mouse_position` instead of just calling
	# `get_global_mouse_position` directly because it needs to be in the same coordinate system
	# as the area (i.e., the main world).
	$%CursorArea.global_position = Cursor.virtual_mouse_position

	# Match the cursor's collision and position to the relative size of the hand.
	_cursor_collision.shape.size = _cursor_collision_original_size / %TransitionCamera.zoom
	_cursor_collision.position = _cursor_collision_original_pos / %TransitionCamera.zoom

# Update whether the simulation is paused based on whether the pause menu is open and stuff. Also
# updates whether we're showing the hardware cursor or the virtual cursor only.
func _update_simulation_pause() -> void:
	var should_pause := is_pause_menu_open() or is_journal_open()
	get_tree().paused = should_pause

	if should_pause: Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else: Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	%VirtualCursor.visible = not should_pause

func _update_scene_overlays() -> void:
	# %SubsceneContainer is visible when the subscene is visible.
	%SubsceneOverlay.visible = %SubsceneContainer.visible
	# The journal and pause menu should never be open simultaneously, so we don't have to do any
	# extra work here to make sure only one is open.
	%JournalOverlay.visible = is_journal_open()
	%PauseOverlay.visible = is_pause_menu_open()

	# TODO: Should this really be here? Should it maybe get its own function?
	# This mirrors the `toggle_menu` input handling in `_unhandled_key_input`.
	%MenuPrompt.show()
	if is_journal_open():
		%MenuPrompt.hide()
	elif is_pause_menu_open() and not %MenuScreenManager.is_on_primary_screen():
		%MenuPrompt.description = "Go back"
	elif _current_module_scene != null:
		if is_pause_menu_open():
			%MenuPrompt.description = "Resume"
		else:
			%MenuPrompt.description = "Pause"
	else:
		%MenuPrompt.hide()

	%JournalPrompt.visible = not is_pause_menu_open()
	%SpeedUpTimePrompt.visible = not is_journal_open() and not is_pause_menu_open()

func _on_menu_screen_manager_screen_changed(_s: MenuScreen) -> void:
	_update_scene_overlays()

func _on_mouse_sensitivity_slider_value_changed(value: float) -> void:
	GameSettings.mouse_sensitivity = value
