extends Node2D

@export var check_strategies: Array[MistakeChecker]
@export var all_modules: Array[ModuleData]

# TODO (update): This is essentially public, so we should consider using a convention to make that
# clear, like naming it in PascalCase.
var current_module_scene: Node = null

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


@onready var _prompt_panel_stylebox_allowed: StyleBox = $%PrimaryPrompt.get_theme_stylebox("panel").duplicate()
@onready var _prompt_panel_stylebox_disallowed: StyleBox = _prompt_panel_stylebox_allowed.duplicate()


var _resolution_options: Array[Vector2i] = [
	Vector2i(1280, 720),
	Vector2i(1366, 768),
	Vector2i(1600, 900),
	Vector2i(1920, 1080),
	Vector2i(2560, 1440),
	Vector2i(3200, 1800),
	Vector2i(3840, 2160),
]

func _ready() -> void:
	_switch_to_main_menu()

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
	$Menu/LogButton/LogMenu.set_tab_icon(1, load("res://Images/Dot-Blue.png"))
	$Menu/LogButton/LogMenu.set_tab_icon(2, load("res://Images/Dot-Yellow.png"))
	$Menu/LogButton/LogMenu.set_tab_icon(3, load("res://Images/Dot-Red.png"))

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

	_prompt_panel_stylebox_disallowed.bg_color.s *= 0.2
	_prompt_panel_stylebox_disallowed.bg_color *= 0.5

func _process(delta: float) -> void:
	if logs != []:
		# Need to display log message(s)
		if !popup_active:
			if logs[0].popup:
				show_popup(logs[0])
			logs.remove_at(0)

	# [kind, name, prompt panel]
	var buttons: Array[Array] = [
		[InteractInfo.Kind.PRIMARY, "Left click", $%PrimaryPrompt],
		[InteractInfo.Kind.SECONDARY, "Right click", $%SecondaryPrompt],
	]

	for b in buttons:
		var kind: InteractInfo.Kind = b[0]
		var name: String = b[1]
		var prompt_panel: PanelContainer = b[2]

		var state: Interaction.InteractState = Interaction.interactions.get(kind)
		if state.info:
			prompt_panel.show()
			if state.info.allowed:
				prompt_panel.add_theme_stylebox_override("panel", _prompt_panel_stylebox_allowed)
			else:
				prompt_panel.add_theme_stylebox_override("panel", _prompt_panel_stylebox_disallowed)

			var label: Label = prompt_panel.get_node("Label")
			label.text = "%s: %s" % [name, state.info.description]
			var color: Color = Color.WHITE
			if state.is_pressed or not state.info.allowed: color = Color.GRAY

			label.add_theme_color_override(&"font_color", color)
		else:
			prompt_panel.hide()

	# THIS STUFF IS TEMPORARY. SUBSTANCES WILL EVENTUALLY BE DISPLAYED IN THE CONTAINERS THEMSELVES,
	# AND MIXING WILL BE DONE WITH A STIR ROD OR BY SWIRLING.
	if Interaction.hovered_interactable is LabBody:
		var containers: Array[ContainerComponent] = []
		containers.assign(Interaction.hovered_interactable.find_children("", "ContainerComponent", false))

		# Show substances in the hovered object.
		$Menu/SubstanceLabel.clear()
		for cc in containers:
			$Menu/SubstanceLabel.add_text("(%.02f°C, %.02f)" % [cc.temperature, cc.mix_amount])
			$Menu/SubstanceLabel.newline()
			for sc in cc.substances:
				$Menu/SubstanceLabel.push_color(sc.get_color())
				if sc is BasicSubstance:
					$Menu/SubstanceLabel.add_text("%.02f mL %s" % [sc.get_volume(), sc.data.name])
				elif sc is SolutionSubstance:
					var solutes_name := ""
					var first := true
					for solute: BasicSubstance in sc.solutes:
						if not first: solutes_name += ", "
						solutes_name += "%.02f mL %s" % [solute.get_volume(), solute.data.name]
						first = false
					$Menu/SubstanceLabel.add_text("solution (%.02f mL %s) {%s}" % [sc.solvent.get_volume(), sc.solvent.data.name, solutes_name])
				else:
					$Menu/SubstanceLabel.add_text("?")
				$Menu/SubstanceLabel.pop()
				$Menu/SubstanceLabel.newline()

		# Mix stuff under the cursor when holding the M key.
		if Input.is_action_pressed(&"mix_container"):
			for cc in containers:
				cc.mix(delta)

func _unhandled_key_input(e: InputEvent) -> void:
	if e.is_action_pressed(&"ToggleMenu") and not TransitionCamera.is_camera_zoomed:
		# A page other than the main pause menu is being shown; return to the pause menu.
		if $Menu/MenuScreens.visible and not $Menu/MenuScreens/PauseMenu.visible:
			_switch_to_menu_screen($Menu/MenuScreens/PauseMenu)
		# Toggle the pause menu only if we're in a module.
		elif current_module_scene != null:
			$Menu/MenuScreens.visible = not $Menu/MenuScreens.visible

func _load_module(module: ModuleData) -> void:
	set_scene(module.scene)

	_switch_to_menu_screen($Menu/MenuScreens/PauseMenu)
	$Menu/Background.hide()
	$Menu/MenuScreens/PauseMenu/Content/Logo.hide()
	$Menu/MenuScreens/PauseMenu/Content/ExitModuleButton.show()
	$Menu/MenuScreens/PauseMenu/Content/RestartModuleButton.show()
	$Menu/MenuScreens.hide()

	current_module = module
	$Menu/LogButton.show()
	$Menu/LogButton/LogMenu/Instructions.text = module.instructions_bb_code
	$Menu/LogButton/LogMenu/Instructions.show()

func check_action(params: Dictionary) -> void:
	for strategy in check_strategies:
		strategy.check_action(params)

func unload_current_module() -> void:
	LabLog.clear_logs()
	for child in $Scene.get_children():
		child.queue_free()

#instanciates scene and adds it as a child of $Scene. Gets rid of any scene that's already been loaded, and hides the menu.
func set_scene(scene: PackedScene) -> void:
	unload_current_module()
	var new_scene := scene.instantiate()
	$Scene.add_child(new_scene)
	current_module_scene = new_scene
	#$Camera.reset()

func get_deepest_subscene_at(pos: Vector2) -> Node:
	var result: Node = null

	var cast_params := PhysicsPointQueryParameters2D.new()
	cast_params.position = pos
	cast_params.collision_mask = 0b10
	cast_params.collide_with_bodies = false
	cast_params.collide_with_areas = true
	var cast_result: Array[Dictionary] = get_world_2d().direct_space_state.intersect_point(cast_params)

	if len(cast_result) > 0:
		#We found results
		for object in cast_result:
			if not object['collider'] is LabObject: #the allowed area of a subscene is not a LabObject
				if object['collider'].get_parent() is SubsceneManager: #^but its parent is the SubsceneManager
					if object['collider'].get_parent().subscene_active and (result == null or object['collider'].get_parent().count_subscene_depth() > result.count_subscene_depth()):
						result = object['collider'].get_parent()
	
	return result

func _unhandled_input(event: InputEvent) -> void:
	###Check if they clicked a LabObject first
	#check if there's any labobjects that need to deal with that input
	#Using the normal object picking (collision objects' input signals) doesn't give us the control we need
	if event.is_action_pressed("DragLabObject"):
		var cast_params := PhysicsPointQueryParameters2D.new()
		cast_params.position = get_global_mouse_position()
		cast_params.collision_mask = 0b10
		cast_params.collide_with_bodies = true
		cast_params.collide_with_areas = true
		var cast_result: Array[Dictionary] = get_world_2d().direct_space_state.intersect_point(cast_params)
		
		if len(cast_result) > 0:
			#We found results: now we need to make sure only objects in the subscene we clicked in (if any) can get this input
			var deepest_subscene := get_deepest_subscene_at(get_global_mouse_position())
			
			var pick_options: Array[LabObject] = []
			for result in cast_result:
				if result['collider'] is LabObject and (result['collider'].get_subscene_manager_parent() == deepest_subscene or (result['collider'] == deepest_subscene and not result['collider'].subscene_active)):
					pick_options.append(result['collider'])
			
			var best_pick: LabObject = null
			for object in pick_options:
				#draggables are better than non draggables, and high z indexes are tie breakers
				if best_pick == null or (
					object.draggable and not best_pick.draggable) or (
					object.z_index > best_pick.z_index and object.draggable == best_pick.draggable):
						best_pick = object
			
			if best_pick:
				if best_pick.draggable:
					best_pick.start_dragging()
				else:
					best_pick.on_user_action()
				get_viewport().set_input_as_handled()
				return

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
	set_scene(current_module.scene)
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
	else:
		push_warning("Tried to set invalid resolution %s" % [resolution])
