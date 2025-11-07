class_name Main
extends Node2D


const INTERACTION_PROMPT_SCENE := preload("res://scenes/interaction_prompt.tscn")


## This will be called with [code]null[/code] when returning to the workspace.
signal camera_focus_owner_changed(focus_owner: Node)

@export var all_modules: Array[ModuleData]

# TODO (update): This is essentially public, so we should consider using a convention to make that
# clear, like naming it in PascalCase.
var current_module_scene: Node = null

var module_button: PackedScene = load("res://scenes/module_select_button.tscn")


var current_module: ModuleData = null

# `Dictionary[LogMessage.Category, int]`.
var unread_logs: Dictionary = {
	LogMessage.Category.LOG: 0,
	LogMessage.Category.WARNING: 0,
	LogMessage.Category.ERROR: 0
}

var popup_active: bool = false
var logs: Array[LogMessage] = []

@onready var _hand_pointing_cursor: Sprite2D = $VirtualCursorLayer/Cursor/HandPointing
@onready var _hand_open_cursor: Sprite2D = $VirtualCursorLayer/Cursor/HandOpen
@onready var _hand_closed_cursor: Sprite2D = $VirtualCursorLayer/Cursor/HandClosed

var _is_paused: bool = true

var _resolution_options: Array[Vector2i] = [
	Vector2i(1280, 720),
	Vector2i(1366, 768),
	Vector2i(1600, 900),
	Vector2i(1920, 1080),
	Vector2i(2560, 1440),
	Vector2i(3200, 1800),
	Vector2i(3840, 2160),
]

var _current_workspace: WorkspaceCamera = null
var _camera_focus_owner: Node = null

var _interact_kind_prompts: Dictionary[InteractInfo.Kind, InteractionPrompt] = {}

func _enter_tree() -> void:
	# These need to be set in `_enter_tree` instead of `_ready` so that we can be pretty sure they
	# are set before any `SubscenePopup` is ready.
	Subscenes.main_world_2d = $%MainViewport.get_world_2d()
	Subscenes.top_level_viewport = get_viewport()

func _ready() -> void:
	Game.main = self
	Game.camera = $%TransitionCamera
	Game.cursor_area = $%CursorArea

	$%SubsceneViewport.world_2d = Subscenes.main_world_2d

	_switch_to_main_menu()
	set_paused(true)

	#Set up the module select buttons
	for module_data in all_modules:
		if module_data.show:
			var new_button := module_button.instantiate()
			new_button.set_data(module_data)
			new_button.connect("pressed", Callable(self, &"_load_module").bind(module_data))
			$%Modules.add_child(new_button)

	#connect the log signals
	LabLog.connect("new_message", Callable(self, "_on_New_Log_Message"))
	LabLog.connect("ReportShown", Callable(self, "_on_LabLog_Report_Shown"))
	LabLog.connect("logs_cleared", Callable(self, "_on_Logs_Cleared"))

	set_log_notification_counts()
	$Menu/LogButton/LogMenu.set_tab_icon(1, load("res://textures/old/Dot-Blue.png"))
	$Menu/LogButton/LogMenu.set_tab_icon(2, load("res://textures/old/Dot-Yellow.png"))
	$Menu/LogButton/LogMenu.set_tab_icon(3, load("res://textures/old/Dot-Red.png"))

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

	%FPSLabel.visible = GameSettings.show_fps

	# The zoom prompt is at the top always.
	_interact_kind_prompts[InteractInfo.Kind.INSPECT] = %ZoomOutPrompt

	# Set the resolution to the one matching the config. If the config resolution doesn't match
	# any of the available ones, then it will automatically choose the first option.
	$%ResolutionDropdown.select(saved_resolution_index)
	_on_resolution_dropdown_item_selected(saved_resolution_index)

	for kind: InteractInfo.Kind in InteractInfo.Kind.values():
		# Don't make a new prompt for one already set previously (like the inspect prompt at the top
		# of the screen.
		if _interact_kind_prompts.has(kind): continue

		var prompt: InteractionPrompt = INTERACTION_PROMPT_SCENE.instantiate()
		var action_event := InputEventAction.new()
		action_event.action = InteractInfo.kind_to_action(kind)
		prompt.input_event = action_event
		%Prompts.add_child(prompt)

		_interact_kind_prompts[kind] = prompt

func _process(delta: float) -> void:
	if logs != []:
		# Need to display log message(s)
		if !popup_active:
			if logs[0].popup:
				show_popup(logs[0])
			logs.remove_at(0)

	for prompt: InteractionPrompt in _interact_kind_prompts.values():
		prompt.hide()

	# Don't show prompts in the main menu.
	if current_module_scene:
		for kind: InteractInfo.Kind in InteractInfo.Kind.values():
			var prompt: InteractionPrompt = _interact_kind_prompts.get(kind)
			if not prompt: continue

			var state: Interaction.InteractState = Interaction.interactions.get(kind)
			if state.info and state.info.show_prompt:
				prompt.show()
				prompt.disabled = not state.info.allowed
				prompt.description = state.info.description
				prompt.pressed = state.is_pressed

	# The coordinate system for the main viewport and the cursor canvas layer are different, so
	# we have to convert.
	var main_to_cursor_canvas: Transform2D = $VirtualCursorLayer.get_final_transform().affine_inverse() * $%MainViewport.canvas_transform
	var cursor_canvas_mouse_pos := main_to_cursor_canvas * Cursor.virtual_mouse_position
	var cursor_canvas_custom_hand_pos := main_to_cursor_canvas * Cursor.custom_hand_position

	# Handle cursor appearance.
	$%Reticle.global_position = cursor_canvas_mouse_pos
	$%Reticle.visible = Cursor.use_custom_hand_position

	for c in $%Cursor.get_children():
		c.hide()
	var cursor_to_use: Sprite2D = _hand_pointing_cursor
	match Cursor.mode:
		Cursor.Mode.OPEN: cursor_to_use = _hand_open_cursor
		Cursor.Mode.CLOSED: cursor_to_use = _hand_closed_cursor
	cursor_to_use.show()

	# TODO: Scale $%CursorArea based on the scale of the main viewport.
	if Cursor.use_custom_hand_position:
		$%Cursor.global_position = cursor_canvas_custom_hand_pos
		$%CursorArea.global_position = Cursor.custom_hand_position
	else:
		$%Cursor.global_position = cursor_canvas_mouse_pos
		# We have to call `$%CursorArea.get_global_mouse_position` instead of just calling
		# `get_global_mouse_position` directly because it needs to be in the same coordinate system
		# as the area (i.e., the main world).
		$%CursorArea.global_position = Cursor.virtual_mouse_position

	%FPSLabel.text = str(Engine.get_frames_per_second())

	%LeftWorkspacePrompt.visible = _current_workspace and not _camera_focus_owner
	%LeftWorkspacePrompt.disabled = _current_workspace and not _current_workspace.left_workspace
	%RightWorkspacePrompt.visible = _current_workspace and not _camera_focus_owner
	%RightWorkspacePrompt.disabled = _current_workspace and not _current_workspace.right_workspace

func _unhandled_key_input(e: InputEvent) -> void:
	if e.is_action_pressed(&"ToggleMenu"):
		# A page other than the main pause menu is being shown; return to the pause menu.
		if is_paused() and not $Menu/MenuScreens/PauseMenu.visible:
			_switch_to_menu_screen($Menu/MenuScreens/PauseMenu)
		# Toggle the pause menu only if we're in a module.
		elif current_module_scene != null:
			set_paused(not is_paused())

func _load_module(module: ModuleData) -> void:
	set_scene(load(module.scene_path))

	_switch_to_menu_screen($Menu/MenuScreens/PauseMenu)
	$Menu/Background.hide()
	$Menu/MenuScreens/PauseMenu/Content/Logo.hide()
	$Menu/MenuScreens/PauseMenu/Content/ExitModuleButton.show()
	$Menu/MenuScreens/PauseMenu/Content/RestartModuleButton.show()

	current_module = module
	$Menu/LogButton.show()
	$Menu/LogButton/LogMenu/Instructions.text = module.instructions_bb_code
	$Menu/LogButton/LogMenu/Instructions.show()

	# To make the initial virtual mouse position feel less weird.
	Cursor.virtual_mouse_position = get_global_mouse_position()
	set_paused(false)

func unload_current_module() -> void:
	LabLog.clear_logs()
	DepthManager.clear_layers()
	for child in $%Scene.get_children():
		child.queue_free()
	move_to_workspace(null)
	current_module_scene = null

#instanciates scene and adds it as a child of %$Scene. Gets rid of any scene that's already been loaded, and hides the menu.
func set_scene(scene: PackedScene) -> void:
	unload_current_module()
	var new_scene := scene.instantiate()
	$%Scene.call_deferred("add_child", new_scene)
	current_module_scene = new_scene
	#$Camera.reset()

func set_popup_border_color(color: Color) -> void:
	$Menu/LabLogPopup/Border.border_color = color

func show_popup(new_log: LogMessage) -> void:
	$Menu/LabLogPopup/Panel/VBoxContainer/Type.text = log_category_to_string(new_log.category)
	$Menu/LabLogPopup/Panel/VBoxContainer/Description.text = new_log.message[0].to_upper() + new_log.message.substr(1, -1)
	var color: Color
	match new_log.category:
		LogMessage.Category.LOG:
			color = Color(0.0, 0.0, 1.0, 1.0)
		LogMessage.Category.WARNING:
			color = Color(1.0, 1.0, 0.0, 1.0)
		LogMessage.Category.ERROR:
			color = Color(1.0, 0.0, 0.0, 1.0)
		_:
			color = Color(0.0, 0.0, 0.0, 0.0)
	set_popup_border_color(color)
	popup_active = true
	$Menu/LabLogPopup.visible = true
	await get_tree().create_timer(GameSettings.popup_timeout).timeout
	popup_active = false
	$Menu/LabLogPopup.visible = false if logs.size() == 0 else true

# Sets whether the pause menu is shown and the game is paused.
func set_paused(paused: bool) -> void:
	_is_paused = paused
	get_tree().paused = _is_paused

	if _is_paused:
		$Menu/MenuScreens.show()
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		$Menu/MenuScreens.hide()
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func is_paused() -> bool:
	return _is_paused

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
func show_subscene(camera: SubsceneCamera, use_overlay: bool = false) -> float:
	var viewport_size := get_viewport_rect().size
	var right_width: float = max(viewport_size.x / 2, camera.region_size.x + 50)
	var padding: float = (right_width - camera.region_size.x) / 2
	camera.custom_viewport = $%SubsceneViewport
	$%SubsceneContainer.size = camera.region_size
	$%SubsceneContainer.position.x = viewport_size.x - right_width + padding
	$%SubsceneContainer.position.y = (viewport_size.y - $%SubsceneContainer.size.y) / 2
	$%SubsceneContainer.show()
	camera.make_current()
	if use_overlay:
		$%SubsceneOverlay.show()
	return viewport_size.x - right_width

func hide_subscene() -> void:
	$%SubsceneContainer.hide()
	$%SubsceneOverlay.hide()

## Show the subscene camera [param camera] on the right side of the screen and use the left side of
## the screen to zoom in on the rectangle [param rect], similarly to [method focus_camera_on_rect].
func focus_camera_and_show_subscene(rect: Rect2, camera: SubsceneCamera, use_overlay: bool = false, time: float = 0.7) -> void:
	var viewport_size := get_viewport().get_visible_rect().size
	var left_width := show_subscene(camera, use_overlay)
	var left_aspect := Vector2(left_width, viewport_size.y).aspect()
	var left_rect := Util.expand_to_aspect(rect.grow(10), left_aspect)
	var full_rect := Util.expand_to_aspect(left_rect, viewport_size.aspect(), 0)
	$%TransitionCamera.move_to_rect(full_rect, false, time)

func _on_SelectModuleButton_pressed() -> void:
	_switch_to_menu_screen($Menu/MenuScreens/ModuleSelect)

func _on_AboutButton_pressed() -> void:
	_switch_to_menu_screen($Menu/MenuScreens/AboutScreen)

func _on_LogButton_pressed() -> void:
	$Menu/LogButton/LogMenu.visible = ! $Menu/LogButton/LogMenu.visible
	set_log_notification_counts()

func _on_New_Log_Message(new_log: LogMessage) -> void:
	if not new_log.hidden:
		var bbcode: String = ("-" + new_log.message + "\n")
		match new_log.category:
			LogMessage.Category.LOG:
				$Menu/LogButton/LogMenu/Log.text += bbcode
			LogMessage.Category.WARNING:
				$Menu/LogButton/LogMenu/Warnings.text += bbcode
			LogMessage.Category.ERROR:
				$Menu/LogButton/LogMenu/Errors.text += bbcode

	logs.append(new_log)
	unread_logs[new_log.category] += 1
	set_log_notification_counts()

func _on_Logs_Cleared() -> void:
	for key: LogMessage.Category in unread_logs.keys():
		unread_logs[key] = 0

	$Menu/LogButton/LogMenu/Log.text = ""
	$Menu/LogButton/LogMenu/Warnings.text = ""
	$Menu/LogButton/LogMenu/Errors.text = ""

# TODO (update): `tab` is unused. We should figure out why this was included.
func set_log_notification_counts(tab: int = -1) -> void:
	if $Menu/LogButton/LogMenu.visible:
		if $Menu/LogButton/LogMenu.current_tab == 1:
			unread_logs[LogMessage.Category.LOG] = 0
		elif $Menu/LogButton/LogMenu.current_tab == 2:
			unread_logs[LogMessage.Category.WARNING] = 0
		#Do not ever clear error notifications
		#elif $LogButton/LogMenu.current_tab == 3:
		#	unread_logs[LogMessage.Category.ERROR] = 0

	if unread_logs[LogMessage.Category.LOG] == 0:
		$Menu/LogButton/LogMenu.set_tab_title(1, "Log")
		$Menu/LogButton/Notifications/Log.hide()
	else:
		$Menu/LogButton/LogMenu.set_tab_title(1, "Log (" + str(unread_logs[LogMessage.Category.LOG]) + "!)")
		$Menu/LogButton/Notifications/Log.show()

	if unread_logs[LogMessage.Category.WARNING] == 0:
		$Menu/LogButton/LogMenu.set_tab_title(2, "Warnings")
		$Menu/LogButton/Notifications/Warning.hide()
	else:
		$Menu/LogButton/LogMenu.set_tab_title(2, "Warnings (" + str(unread_logs[LogMessage.Category.WARNING]) + "!)")
		$Menu/LogButton/Notifications/Warning.show()

	if unread_logs[LogMessage.Category.ERROR] == 0:
		$Menu/LogButton/LogMenu.set_tab_title(3, "Errors")
		$Menu/LogButton/Notifications/Error.hide()
	else:
		$Menu/LogButton/LogMenu.set_tab_title(3, "Errors (" + str(unread_logs[LogMessage.Category.ERROR]) + "!)")
		$Menu/LogButton/Notifications/Error.show()

func _on_LabLog_Report_Shown() -> void:
	#Show all the warnings and errors
	var logs_text := ""
	for warning in LabLog.get_logs(LogMessage.Category.WARNING):
		logs_text += "[color=yellow]-" + warning.message + "[/color]\n"
	for error in LabLog.get_logs(LogMessage.Category.ERROR):
		logs_text += "[color=red]-" + error.message + "[/color]\n"

	if logs_text != "":
		logs_text = "You weren't perfect though - here's some notes:\n" + logs_text
		$Menu/FinalReport/VBoxContainer/Logs.text = logs_text
		$Menu/FinalReport/VBoxContainer/Logs.show()
	else:
		$Menu/FinalReport/VBoxContainer/Logs.hide()

	#Setup the rest of the popup
	$Menu/FinalReport/VBoxContainer/ModuleName.text = "You completed the \"" + current_module.name + "\" module!"
	$Menu/FinalReport/VBoxContainer/ModuleIcon.texture = current_module.thumbnail
	$Menu/FinalReport.set_anchors_preset(Control.PRESET_CENTER)
	$Menu/FinalReport.show()

func _on_FinalReport_MainMenuButton_pressed() -> void:
	get_tree().reload_current_scene()

func _on_FinalReport_RestartModuleButton_pressed() -> void:
	set_scene(load(current_module.scene_path))
	set_log_notification_counts()
	$Menu/FinalReport.hide()

func _on_FinalReport_ContinueButton_pressed() -> void:
	_switch_to_menu_screen($Menu/MenuScreens/PauseMenu)

func _on_About_CloseButton_pressed() -> void:
	_switch_to_menu_screen($Menu/MenuScreens/PauseMenu)

func _on_OptionsButton_pressed() -> void:
	_switch_to_menu_screen($Menu/MenuScreens/OptionsScreen)
	$Menu/MenuScreens/OptionsScreen/VBoxContainer/MouseDragToggle.button_pressed = GameSettings.mouse_camera_drag
	$Menu/MenuScreens/OptionsScreen/VBoxContainer/ObjectTooltipsToggle.button_pressed = GameSettings.object_tooltips
	$Menu/MenuScreens/OptionsScreen/VBoxContainer/PopupDuration/PopupTimeout.value = GameSettings.popup_timeout

func _on_CloseButton_pressed() -> void:
	_switch_to_menu_screen($Menu/MenuScreens/PauseMenu)

func _on_MouseDragToggle_toggled(button_pressed: bool) -> void:
	GameSettings.mouse_camera_drag = button_pressed

func _on_ObjectTooltipsToggle_toggled(button_pressed: bool) -> void:
	GameSettings.object_tooltips = button_pressed

func _on_PopupTimeout_value_changed(value: float) -> void:
	GameSettings.popup_timeout = value

static func log_category_to_string(category: LogMessage.Category) -> String:
	return LogMessage.Category.keys()[category].to_lower()

func _on_exit_module_button_pressed() -> void:
	_switch_to_main_menu()

func _switch_to_main_menu() -> void:
	unload_current_module()

	_switch_to_menu_screen($Menu/MenuScreens/PauseMenu)
	$Menu/MenuScreens/PauseMenu/Content/Logo.hide()
	$Menu/MenuScreens/PauseMenu/Content/ExitModuleButton.hide()
	$Menu/MenuScreens/PauseMenu/Content/RestartModuleButton.hide()
	$Menu/Background.show()

	$Menu/LogButton.hide() #until we load a module
	$Menu/LogButton/LogMenu.hide()
	$Menu/FinalReport.hide()
	$Menu/LabLogPopup.hide()

# Only one of the UI elements in `$MenuScreens` can be shown at once. These are
# the UI elements that show up in the middle of the screen, and them overlapping is problematic.
func _switch_to_menu_screen(menu: Control) -> void:
	if not $Menu/MenuScreens.get_children().has(menu): return
	for m in $Menu/MenuScreens.get_children():
		m.hide()
	menu.show()

func _on_quit_button_pressed() -> void:
	get_tree().quit()

func _on_restart_module_button_pressed() -> void:
	_load_module(current_module)

func _on_module_select_close_button_pressed() -> void:
	_switch_to_menu_screen($Menu/MenuScreens/PauseMenu)

func _on_resolution_dropdown_item_selected(index: int) -> void:
	var resolution: Variant = $%ResolutionDropdown.get_item_metadata(index)
	if resolution is Vector2i:
		GameSettings.resolution = resolution
		get_window().size = resolution
		get_window().move_to_center()
		$%MainViewport.size = resolution
	else:
		push_warning("Tried to set invalid resolution %s" % [resolution])

func _on_cursor_area_body_entered(body: Node2D) -> void:
	if body is LabBody: body.is_moused_over = true

func _on_cursor_area_body_exited(body: Node2D) -> void:
	if body is LabBody: body.is_moused_over = false

func _on_show_fps_toggled(toggled_on: bool) -> void:
	GameSettings.show_fps = toggled_on
	%FPSLabel.visible = toggled_on

func _on_interactable_system_pressed_left() -> void:
	if _current_workspace and _current_workspace.left_workspace and not _camera_focus_owner:
		move_to_workspace(_current_workspace.left_workspace, 1.0)

func _on_interactable_system_pressed_right() -> void:
	if _current_workspace and _current_workspace.right_workspace and not _camera_focus_owner:
		move_to_workspace(_current_workspace.right_workspace, 1.0)

func _on_interactable_system_pressed_zoom_out() -> void:
	if _camera_focus_owner: return_to_current_workspace()
