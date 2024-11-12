extends CanvasLayer

var ModuleDirectory: String = "res://Modules/"
var ModuleButton: PackedScene = load("res://Scenes/UI/ModuleSelectButton.tscn")

var currentModule: ModuleData = null

var unreadLogs: Dictionary = {'log': 0, 'warning': 0, 'error': 0}

var popupActive: bool = false
var logs: Array = []

#This function is mostly copied from online.
#It seems like godot 3.5 does not have a convenient function for this.
func GetAllFilesInFolder(path: String) -> Array[String]:
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
	$MainMenu.hide()
	$ModuleSelect.hide()
	$OptionsScreen.hide()
	$AboutScreen.hide()
	$LogButton.hide() #until we load a module
	$LogButton/LogMenu.hide()
	$FinalReport.hide()
	$LabLogPopup.hide()
	$MainMenu/Content/Logo.hide()
	
	#Set up the module select buttons
	for file in GetAllFilesInFolder(ModuleDirectory):
		var moduleData: ModuleData = load(ModuleDirectory + file)
		if moduleData.Show:
			var newButton := ModuleButton.instantiate()
			newButton.SetData(moduleData)
			newButton.connect("pressed", Callable(self, "ModuleSelected").bind(moduleData))
			$ModuleSelect.add_child(newButton)
	
	#connect the log signals
	LabLog.connect("NewMessage", Callable(self, "_on_New_Log_Message"))
	LabLog.connect("ReportShown", Callable(self, "_on_LabLog_Report_Shown"))
	LabLog.connect("LogsCleared", Callable(self, "_on_Logs_Cleared"))
	
	SetLogNotificationCounts()
	$LogButton/LogMenu.set_tab_icon(1, load("res://Images/Dot-Blue.png"))
	$LogButton/LogMenu.set_tab_icon(2, load("res://Images/Dot-Yellow.png"))
	$LogButton/LogMenu.set_tab_icon(3, load("res://Images/Dot-Red.png"))
	
	# Since there is one module, it should boot directly into this scene
	var module: ModuleData = load(ModuleDirectory + "GelElectrophoresis.tres")
	ModuleSelected(module)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ToggleMenu"):
		if $MainMenu.visible:
			$MainMenu.hide()
		else:
			$MainMenu.show()
			$ModuleSelect.hide()
			$AboutScreen.hide()
			$LogButton/LogMenu.hide()
			$OptionsScreen.hide()
			$MainMenu/Background.visible = (get_parent().currentModuleScene == null)
			$MainMenu/Content/Logo.visible = not (get_parent().currentModuleScene == null)
			
	if logs != []:
		# Need to display log message(s)
		if !popupActive:
			if logs[0]['newLog']['popup']:
				ShowPopup(logs[0]['category'], logs[0]['newLog'])
			logs.remove_at(0)

func ModuleSelected(module: ModuleData) -> void:
	get_parent().SetScene(module.Scene)
	$ModuleSelect.hide()
	currentModule = module
	$LogButton.show()
	$LogButton/LogMenu/Instructions.text = module.InstructionsBBCode

func _on_SelectModuleButton_pressed() -> void:
	$MainMenu.hide()
	$ModuleSelect.show()

func _on_AboutButton_pressed() -> void:
	$AboutScreen.show()

func _on_LogButton_pressed() -> void:
	$LogButton/LogMenu.visible = ! $LogButton/LogMenu.visible
	SetLogNotificationCounts()

func _on_New_Log_Message(category: String, newLog: Dictionary) -> void:
	if not newLog['hidden']:
		var bbcode: String = ("-" + newLog['message'] + "\n")
		if category == 'log':
			unreadLogs['log'] += 1
			$LogButton/LogMenu/Log.text += bbcode
		elif category == 'warning':
			unreadLogs['warning'] += 1
			$LogButton/LogMenu/Warnings.text += bbcode
		elif category == 'error':
			unreadLogs['error'] += 1
			$LogButton/LogMenu/Errors.text += bbcode
	logs.append({
		'category': category, 
		'newLog': newLog
	})
	SetLogNotificationCounts()

func ShowPopup(category: String, newLog: Dictionary) -> void:
	$LabLogPopup/Panel/VBoxContainer/Type.text = category.capitalize()
	$LabLogPopup/Panel/VBoxContainer/Description.text = newLog['message'][0].to_upper() + newLog['message'].substr(1, -1)
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
	SetPopupBorderColor(color)
	popupActive = true
	$LabLogPopup.visible = true
	await get_tree().create_timer(GameSettings.popupTimeout).timeout
	popupActive = false
	$LabLogPopup.visible = false if logs.size() == 0 else true

func SetPopupBorderColor(color: Color) -> void:
	$LabLogPopup/Border.border_color = color

func _on_Logs_Cleared() -> void:
	unreadLogs['log'] = 0
	unreadLogs['warning'] = 0
	unreadLogs['error'] = 0
	$LogButton/LogMenu/Log.text = ""
	$LogButton/LogMenu/Warnings.text = ""
	$LogButton/LogMenu/Errors.text = ""

# TODO (update): `tab` is unused. We should figure out why this was included.
func SetLogNotificationCounts(tab: int = -1) -> void:
	if $LogButton/LogMenu.visible:
		if $LogButton/LogMenu.current_tab == 1:
			unreadLogs['log'] = 0
		elif $LogButton/LogMenu.current_tab == 2:
			unreadLogs['warning'] = 0
		#Do not ever clear error notifications
		#elif $LogButton/LogMenu.current_tab == 3:
		#	unreadLogs['error'] = 0
	
	if unreadLogs['log'] == 0:
		$LogButton/LogMenu.set_tab_title(1, "Log")
		$LogButton/Notifications/Log.hide()
	else:
		$LogButton/LogMenu.set_tab_title(1, "Log (" + str(unreadLogs['log']) + "!)")
		$LogButton/Notifications/Log.show()
	
	if unreadLogs['warning'] == 0:
		$LogButton/LogMenu.set_tab_title(2, "Warnings")
		$LogButton/Notifications/Warning.hide()
	else:
		$LogButton/LogMenu.set_tab_title(2, "Warnings (" + str(unreadLogs['warning']) + "!)")
		$LogButton/Notifications/Warning.show()
	
	if unreadLogs['error'] == 0:
		$LogButton/LogMenu.set_tab_title(3, "Errors")
		$LogButton/Notifications/Error.hide()
	else:
		$LogButton/LogMenu.set_tab_title(3, "Errors (" + str(unreadLogs['error']) + "!)")
		$LogButton/Notifications/Error.show()

func _on_LabLog_Report_Shown() -> void:
	#Show all the warnings and errors
	var logsText := ""
	var allLogs: Dictionary = LabLog.GetLogs()
	for warning: Dictionary in allLogs.get('warning', []):
		logsText += "[color=yellow]-" + warning['message'] + "[/color]\n"
	for error: Dictionary in allLogs.get('error', []):
		logsText += "[color=red]-" + error['message'] + "[/color]\n"
	
	if logsText != "":
		logsText = "You weren't perfect though - here's some notes:\n" + logsText
		$FinalReport/VBoxContainer/Logs.text = logsText
		$FinalReport/VBoxContainer/Logs.show()
	else:
		$FinalReport/VBoxContainer/Logs.hide()
	
	#Setup the rest of the popup
	$FinalReport/VBoxContainer/ModuleName.text = "You completed the \"" + currentModule.Name + "\" module!"
	$FinalReport/VBoxContainer/ModuleIcon.texture = currentModule.Thumbnail
	$FinalReport.set_anchors_preset(Control.PRESET_CENTER)
	$FinalReport.show()

func _on_FinalReport_MainMenuButton_pressed() -> void:
	get_tree().reload_current_scene()

func _on_FinalReport_RestartModuleButton_pressed() -> void:
	get_parent().SetScene(currentModule.Scene)
	SetLogNotificationCounts()
	$FinalReport.hide()

func _on_FinalReport_ContinueButton_pressed() -> void:
	$FinalReport.hide()

func _on_About_CloseButton_pressed() -> void:
	$AboutScreen.hide()

func _on_OptionsButton_pressed() -> void:
	$OptionsScreen.show()
	$OptionsScreen/VBoxContainer/MouseDragToggle.button_pressed = GameSettings.mouseCameraDrag
	$OptionsScreen/VBoxContainer/ObjectTooltipsToggle.button_pressed = GameSettings.objectTooltips
	$OptionsScreen/VBoxContainer/PopupDuration/PopupTimeout.value = GameSettings.popupTimeout

func _on_CloseButton_pressed() -> void:
	$OptionsScreen.hide()

func _on_MouseDragToggle_toggled(button_pressed: bool) -> void:
	GameSettings.mouseCameraDrag = button_pressed

func _on_ObjectTooltipsToggle_toggled(button_pressed: bool) -> void:
	GameSettings.objectTooltips = button_pressed

func _on_PopupTimeout_value_changed(value: float) -> void:
	GameSettings.popupTimeout = value
