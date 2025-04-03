extends CanvasLayer

var module_directory: String = "res://Modules/"
var module_button: PackedScene = load("res://Scenes/UI/ModuleSelectButton.tscn")

var current_module: ModuleData = null

var unread_logs: Dictionary = {'log': 0, 'warning': 0, 'error': 0}

var popup_active: bool = false
var logs: Array[Dictionary] = []

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
	# Due to having one module, the MainMenu should be hidden by default
	# When more modules are added, it is likely a good idea to show MainMenu by default
	$MainMenu.show()
	$ModuleSelect.show()
	$OptionsScreen.hide()
	$AboutScreen.hide()
	$LogButton.hide() #until we load a module
	$LogButton/LogMenu.hide()
	$FinalReport.hide()
	$LabLogPopup.hide()
	$MainMenu/Content/Logo.hide()
	
	#Set up the module select buttons
	for file in get_all_files_in_folder(module_directory):
		var module_data: ModuleData = load(module_directory + file)
		if module_data.show:
			var new_button := module_button.instantiate()
			new_button.set_data(module_data)
			new_button.connect("pressed", Callable(self, "module_selected").bind(module_data))
			$ModuleSelect.add_child(new_button)
	
	#connect the log signals
	LabLog.connect("new_message", Callable(self, "_on_New_Log_Message"))
	LabLog.connect("ReportShown", Callable(self, "_on_LabLog_Report_Shown"))
	LabLog.connect("logs_cleared", Callable(self, "_on_Logs_Cleared"))
	
	set_log_notification_counts()
	$LogButton/LogMenu.set_tab_icon(1, load("res://Images/Dot-Blue.png"))
	$LogButton/LogMenu.set_tab_icon(2, load("res://Images/Dot-Yellow.png"))
	$LogButton/LogMenu.set_tab_icon(3, load("res://Images/Dot-Red.png"))
	
	# Since there is one module, it should boot directly into this scene
	var module: ModuleData = load(module_directory + "GelElectrophoresis.tres")
	module_selected(module)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ToggleMenu"):
		if $MainMenu.visible:
			$MainMenu.hide()
		else:
			$MainMenu.show()
			$ModuleSelect.show()
			$AboutScreen.hide()
			$LogButton/LogMenu.hide()
			$OptionsScreen.hide()
			$MainMenu/Background.visible = (get_parent().current_module_scene == null)
			$MainMenu/Content/Logo.visible = not (get_parent().current_module_scene == null)
			
	if logs != []:
		# Need to display log message(s)
		if !popup_active:
			if logs[0]['new_log']['popup']:
				show_popup(logs[0]['category'], logs[0]['new_log'])
			logs.remove_at(0)


func module_selected(module: ModuleData) -> void:
	get_parent().set_scene(module.scene)
	$ModuleSelect.hide()
	current_module = module
	$LogButton.show()
	$LogButton/LogMenu/Instructions.text = module.instructions_bb_code

func _on_SelectModuleButton_pressed() -> void:
	$MainMenu.hide()
	$ModuleSelect.show()

func _on_AboutButton_pressed() -> void:
	$AboutScreen.show()

func _on_LogButton_pressed() -> void:
	$LogButton/LogMenu.visible = ! $LogButton/LogMenu.visible
	set_log_notification_counts()

func _on_New_Log_Message(category: String, new_log: Dictionary) -> void:
	if not new_log['hidden']:
		var bbcode: String = ("-" + new_log['message'] + "\n")
		if category == 'log':
			unread_logs['log'] += 1
			$LogButton/LogMenu/Log.text += bbcode
		elif category == 'warning':
			unread_logs['warning'] += 1
			$LogButton/LogMenu/Warnings.text += bbcode
		elif category == 'error':
			unread_logs['error'] += 1
			$LogButton/LogMenu/Errors.text += bbcode
	logs.append({
		'category': category, 
		'new_log': new_log
	})
	set_log_notification_counts()

func show_popup(category: String, new_log: Dictionary) -> void:
	$LabLogPopup/Panel/VBoxContainer/Type.text = category.capitalize()
	$LabLogPopup/Panel/VBoxContainer/Description.text = new_log['message'][0].to_upper() + new_log['message'].substr(1, -1)
	var color: Color
	match category:
		"log":
			color = Color(0.0, 0.0, 1.0, 1.0)
		"warning":
			color = Color(1.0, 1.0, 0.0, 1.0)
		"error":
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
	unread_logs['log'] = 0
	unread_logs['warning'] = 0
	unread_logs['error'] = 0
	$LogButton/LogMenu/Log.text = ""
	$LogButton/LogMenu/Warnings.text = ""
	$LogButton/LogMenu/Errors.text = ""

# TODO (update): `tab` is unused. We should figure out why this was included.
func set_log_notification_counts(tab: int = -1) -> void:
	if $LogButton/LogMenu.visible:
		if $LogButton/LogMenu.current_tab == 1:
			unread_logs['log'] = 0
		elif $LogButton/LogMenu.current_tab == 2:
			unread_logs['warning'] = 0
		#Do not ever clear error notifications
		#elif $LogButton/LogMenu.current_tab == 3:
		#	unread_logs['error'] = 0
	
	if unread_logs['log'] == 0:
		$LogButton/LogMenu.set_tab_title(1, "Log")
		$LogButton/Notifications/Log.hide()
	else:
		$LogButton/LogMenu.set_tab_title(1, "Log (" + str(unread_logs['log']) + "!)")
		$LogButton/Notifications/Log.show()
	
	if unread_logs['warning'] == 0:
		$LogButton/LogMenu.set_tab_title(2, "Warnings")
		$LogButton/Notifications/Warning.hide()
	else:
		$LogButton/LogMenu.set_tab_title(2, "Warnings (" + str(unread_logs['warning']) + "!)")
		$LogButton/Notifications/Warning.show()
	
	if unread_logs['error'] == 0:
		$LogButton/LogMenu.set_tab_title(3, "Errors")
		$LogButton/Notifications/Error.hide()
	else:
		$LogButton/LogMenu.set_tab_title(3, "Errors (" + str(unread_logs['error']) + "!)")
		$LogButton/Notifications/Error.show()

func _on_LabLog_Report_Shown() -> void:
	#Show all the warnings and errors
	var logs_text := ""
	var all_logs: Dictionary = LabLog.get_logs()
	for warning: Dictionary in all_logs.get('warning', []):
		logs_text += "[color=yellow]-" + warning['message'] + "[/color]\n"
	for error: Dictionary in all_logs.get('error', []):
		logs_text += "[color=red]-" + error['message'] + "[/color]\n"
	
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
	$FinalReport.hide()

func _on_About_CloseButton_pressed() -> void:
	$AboutScreen.hide()

func _on_OptionsButton_pressed() -> void:
	$OptionsScreen.show()
	$OptionsScreen/VBoxContainer/MouseDragToggle.button_pressed = GameSettings.mouse_camera_drag
	$OptionsScreen/VBoxContainer/ObjectTooltipsToggle.button_pressed = GameSettings.object_tooltips
	$OptionsScreen/VBoxContainer/PopupDuration/PopupTimeout.value = GameSettings.popup_timeout

func _on_CloseButton_pressed() -> void:
	$OptionsScreen.hide()

func _on_MouseDragToggle_toggled(button_pressed: bool) -> void:
	GameSettings.mouse_camera_drag = button_pressed

func _on_ObjectTooltipsToggle_toggled(button_pressed: bool) -> void:
	GameSettings.object_tooltips = button_pressed

func _on_PopupTimeout_value_changed(value: float) -> void:
	GameSettings.popup_timeout = value
