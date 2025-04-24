extends CanvasLayer

var module_directory: String = "res://Modules/"
var module_button: PackedScene = load("res://Scenes/UI/ModuleSelectButton.tscn")

var current_module: ModuleData = null

# `Dictionary[LogMessage.Category, int]`.
var unread_logs: Dictionary = {
	LogMessage.Category.LOG: 0,
	LogMessage.Category.WARNING: 0,
	LogMessage.Category.ERROR: 0
}

var popup_active: bool = false
var logs: Array[LogMessage] = []

#This function is mostly copied from online.
#It seems like godot 3.5 does not have a convenient function for this.
func get_all_files_in_folder(path: String) -> Array[String]:
	var result: Array[String] = []

	var dir: DirAccess = DirAccess.open(path)
	if dir != null:
		dir.list_dir_begin()  #skip . and .. but don't skop hidden files# TODOConverter3To4 fill missing arguments https://github.com/godotengine/godot/pull/40547
		var file_name: String = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir():
				result.append(file_name)
			file_name = dir.get_next()
	else:
		print("Couldn't open \"" + path + "\"")
	return result

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_switch_to_main_menu()

	#Set up the module select buttons
	for file in get_all_files_in_folder(module_directory):
		var module_data: ModuleData = load(module_directory + file)
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
	$LogButton/LogMenu.set_tab_icon(1, load("res://Images/Dot-Blue.png"))
	$LogButton/LogMenu.set_tab_icon(2, load("res://Images/Dot-Yellow.png"))
	$LogButton/LogMenu.set_tab_icon(3, load("res://Images/Dot-Red.png"))

func _process(delta: float) -> void:
	if logs != []:
		# Need to display log message(s)
		if !popup_active:
			if logs[0].popup:
				show_popup(logs[0])
			logs.remove_at(0)

func _unhandled_key_input(e: InputEvent) -> void:
	if e.is_action_pressed(&"ToggleMenu"):
		# A page other than the main pause menu is being shown; return to the pause menu.
		if $MenuScreens.visible and not $MenuScreens/PauseMenu.visible:
			_switch_to_menu_screen($MenuScreens/PauseMenu)
		# Toggle the pause menu only if we're in a module.
		elif $"..".current_module_scene != null:
			$MenuScreens.visible = not $MenuScreens.visible

func _load_module(module: ModuleData) -> void:
	get_parent().set_scene(module.scene)

	_switch_to_menu_screen($MenuScreens/PauseMenu)
	$Background.hide()
	$MenuScreens/PauseMenu/Content/Logo.show()
	$MenuScreens/PauseMenu/Content/ExitModuleButton.show()
	$MenuScreens/PauseMenu/Content/RestartModuleButton.show()
	$MenuScreens.hide()

	current_module = module
	$LogButton.show()
	$LogButton/LogMenu/Instructions.text = module.instructions_bb_code
	$LogButton/LogMenu/Instructions.show()

func _on_SelectModuleButton_pressed() -> void:
	_switch_to_menu_screen($MenuScreens/ModuleSelect)

func _on_AboutButton_pressed() -> void:
	_switch_to_menu_screen($MenuScreens/AboutScreen)

func _on_LogButton_pressed() -> void:
	$LogButton/LogMenu.visible = ! $LogButton/LogMenu.visible
	set_log_notification_counts()

func _on_New_Log_Message(new_log: LogMessage) -> void:
	if not new_log.hidden:
		var bbcode: String = ("-" + new_log.message + "\n")
		match new_log.category:
			LogMessage.Category.LOG:
				$LogButton/LogMenu/Log.text += bbcode
			LogMessage.Category.WARNING:
				$LogButton/LogMenu/Warnings.text += bbcode
			LogMessage.Category.ERROR:
				$LogButton/LogMenu/Errors.text += bbcode

	logs.append(new_log)
	unread_logs[new_log.category] += 1
	set_log_notification_counts()

func show_popup(new_log: LogMessage) -> void:
	$LabLogPopup/Panel/VBoxContainer/Type.text = log_category_to_string(new_log.category)
	$LabLogPopup/Panel/VBoxContainer/Description.text = new_log.message[0].to_upper() + new_log.message.substr(1, -1)
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
	$LabLogPopup.visible = true
	await get_tree().create_timer(GameSettings.popup_timeout).timeout
	popup_active = false
	$LabLogPopup.visible = false if logs.size() == 0 else true

func set_popup_border_color(color: Color) -> void:
	$LabLogPopup/Border.border_color = color

func _on_Logs_Cleared() -> void:
	for key: LogMessage.Category in unread_logs.keys():
		unread_logs[key] = 0

	$LogButton/LogMenu/Log.text = ""
	$LogButton/LogMenu/Warnings.text = ""
	$LogButton/LogMenu/Errors.text = ""

# TODO (update): `tab` is unused. We should figure out why this was included.
func set_log_notification_counts(tab: int = -1) -> void:
	if $LogButton/LogMenu.visible:
		if $LogButton/LogMenu.current_tab == 1:
			unread_logs[LogMessage.Category.LOG] = 0
		elif $LogButton/LogMenu.current_tab == 2:
			unread_logs[LogMessage.Category.WARNING] = 0
		#Do not ever clear error notifications
		#elif $LogButton/LogMenu.current_tab == 3:
		#	unread_logs[LogMessage.Category.ERROR] = 0

	if unread_logs[LogMessage.Category.LOG] == 0:
		$LogButton/LogMenu.set_tab_title(1, "Log")
		$LogButton/Notifications/Log.hide()
	else:
		$LogButton/LogMenu.set_tab_title(1, "Log (" + str(unread_logs[LogMessage.Category.LOG]) + "!)")
		$LogButton/Notifications/Log.show()

	if unread_logs[LogMessage.Category.WARNING] == 0:
		$LogButton/LogMenu.set_tab_title(2, "Warnings")
		$LogButton/Notifications/Warning.hide()
	else:
		$LogButton/LogMenu.set_tab_title(2, "Warnings (" + str(unread_logs[LogMessage.Category.WARNING]) + "!)")
		$LogButton/Notifications/Warning.show()

	if unread_logs[LogMessage.Category.ERROR] == 0:
		$LogButton/LogMenu.set_tab_title(3, "Errors")
		$LogButton/Notifications/Error.hide()
	else:
		$LogButton/LogMenu.set_tab_title(3, "Errors (" + str(unread_logs[LogMessage.Category.ERROR]) + "!)")
		$LogButton/Notifications/Error.show()

func _on_LabLog_Report_Shown() -> void:
	#Show all the warnings and errors
	var logs_text := ""
	for warning in LabLog.get_logs(LogMessage.Category.WARNING):
		logs_text += "[color=yellow]-" + warning.message + "[/color]\n"
	for error in LabLog.get_logs(LogMessage.Category.ERROR):
		logs_text += "[color=red]-" + error.message + "[/color]\n"

	if logs_text != "":
		logs_text = "You weren't perfect though - here's some notes:\n" + logs_text
		$FinalReport/VBoxContainer/Logs.text = logs_text
		$FinalReport/VBoxContainer/Logs.show()
	else:
		$FinalReport/VBoxContainer/Logs.hide()

	#Setup the rest of the popup
	$FinalReport/VBoxContainer/ModuleName.text = "You completed the \"" + current_module.name + "\" module!"
	$FinalReport/VBoxContainer/ModuleIcon.texture = current_module.thumbnail
	$FinalReport.set_anchors_preset(Control.PRESET_CENTER)
	$FinalReport.show()

func _on_FinalReport_MainMenuButton_pressed() -> void:
	get_tree().reload_current_scene()

func _on_FinalReport_RestartModuleButton_pressed() -> void:
	get_parent().set_scene(current_module.scene)
	set_log_notification_counts()
	$FinalReport.hide()

func _on_FinalReport_ContinueButton_pressed() -> void:
	_switch_to_menu_screen($MenuScreens/PauseMenu)

func _on_About_CloseButton_pressed() -> void:
	_switch_to_menu_screen($MenuScreens/PauseMenu)

func _on_OptionsButton_pressed() -> void:
	_switch_to_menu_screen($MenuScreens/OptionsScreen)
	$MenuScreens/OptionsScreen/VBoxContainer/MouseDragToggle.button_pressed = GameSettings.mouse_camera_drag
	$MenuScreens/OptionsScreen/VBoxContainer/ObjectTooltipsToggle.button_pressed = GameSettings.object_tooltips
	$MenuScreens/OptionsScreen/VBoxContainer/PopupDuration/PopupTimeout.value = GameSettings.popup_timeout

func _on_CloseButton_pressed() -> void:
	_switch_to_menu_screen($MenuScreens/PauseMenu)

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
	$"..".unload_current_module()

	_switch_to_menu_screen($MenuScreens/PauseMenu)
	$MenuScreens/PauseMenu/Content/Logo.hide()
	$MenuScreens/PauseMenu/Content/ExitModuleButton.hide()
	$MenuScreens/PauseMenu/Content/RestartModuleButton.hide()
	$Background.show()

	$LogButton.hide() #until we load a module
	$LogButton/LogMenu.hide()
	$FinalReport.hide()
	$LabLogPopup.hide()

# Only one of the UI elements in `$MenuScreens` can be shown at once. These are
# the UI elements that show up in the middle of the screen, and them overlapping is problematic.
func _switch_to_menu_screen(menu: Control) -> void:
	if not $MenuScreens.get_children().has(menu): return
	for m in $MenuScreens.get_children():
		m.hide()
	menu.show()

func _on_quit_button_pressed() -> void:
	get_tree().quit()

func _on_restart_module_button_pressed() -> void:
	_load_module(current_module)

func _on_module_select_close_button_pressed() -> void:
	_switch_to_menu_screen($MenuScreens/PauseMenu)
