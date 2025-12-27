extends Node

var settings_save: SettingsSave

func _ready() -> void:
	DebugLogger.log_manager_init("AudioManager - START")
	load_and_apply_settings()
	DebugLogger.log_manager_init("SettingsManager - COMPLETE")

func load_and_apply_settings() -> void:
	DebugLogger.log_info("Loading settings...")
	var save_path = "user://settings.tres"
	
	var file_exists = false

	if OS.has_feature("web"):
		DebugLogger.log_info("Web build - skipping file check")
	elif OS.has_feature("android") or OS.has_feature("ios"):
		DebugLogger.log_info("Mobile build - checking file with FileAccess")
		var file = FileAccess.open(save_path, FileAccess.READ)
		file_exists = file != null
		if file:
			file.close()
		DebugLogger.log_info("Settings file exists: " + str(file_exists))
	else:
		file_exists = FileAccess.file_exists(save_path)
		DebugLogger.log_info("Settings file exists: " + str(file_exists))
	
	if file_exists:
		settings_save = ResourceLoader.load(save_path, "", ResourceLoader.CACHE_MODE_IGNORE) as SettingsSave
		if settings_save:
			DebugLogger.log_info("Loaded settings from file")
		else:
			DebugLogger.log_warning("Settings file exists but failed to load")
	
	if settings_save == null:
		DebugLogger.log_info("Creating new settings")
		settings_save = SettingsSave.new()
		if settings_save.control_mappings.is_empty():
			settings_save.set_default_controls()
		save_settings()
	
	DebugLogger.log_info("Applying audio settings...")
	apply_audio_settings()
	DebugLogger.log_info("Applying control mappings...")
	apply_control_mappings()
	DebugLogger.log_info("Settings loaded successfully")

func apply_audio_settings() -> void:
	var music_db = linear_to_db(settings_save.music_volume / 100.0)
	var sfx_db = linear_to_db(settings_save.sfx_volume / 100.0)
	
	var music_bus_idx = AudioServer.get_bus_index("Music")
	var sfx_bus_idx = AudioServer.get_bus_index("SFX")
	
	if music_bus_idx >= 0:
		AudioServer.set_bus_volume_db(music_bus_idx, music_db)
		DebugLogger.log_info("Music volume set: " + str(music_db))
	else:
		DebugLogger.log_warning("Music bus not found!")
	
	if sfx_bus_idx >= 0:
		AudioServer.set_bus_volume_db(sfx_bus_idx, sfx_db)
		DebugLogger.log_info("SFX volume set: " + str(sfx_db))
	else:
		DebugLogger.log_warning("SFX bus not found!")

func apply_control_mappings() -> void:
	var actions = InputMap.get_actions()
	
	for action in actions:
		var has_key_save = settings_save.control_mappings.has(action)
		var has_btn_save = settings_save.controller_buttons.has(action)
		var has_axis_save = settings_save.controller_axes.has(action)
		
		if not (has_key_save or has_btn_save or has_axis_save):
			continue
		
		InputMap.action_erase_events(action)

		if has_key_save:
			var keycode = settings_save.control_mappings[action]
			var key_event = InputEventKey.new()
			key_event.physical_keycode = keycode
			InputMap.action_add_event(action, key_event)

		if has_btn_save:
			var button_index = settings_save.controller_buttons[action]
			var joy_event = InputEventJoypadButton.new()
			joy_event.button_index = button_index
			InputMap.action_add_event(action, joy_event)

		if has_axis_save:
			var axis_data = settings_save.controller_axes[action]
			var joy_motion = InputEventJoypadMotion.new()
			joy_motion.axis = axis_data["axis"]
			joy_motion.axis_value = axis_data["value"]
			InputMap.action_add_event(action, joy_motion)

		_restore_secondary_bindings(action)

func _restore_secondary_bindings(action: String) -> void:
	if action == "move-left":
		_add_joy_btn(action, JOY_BUTTON_DPAD_LEFT)
	elif action == "move-right":
		_add_joy_btn(action, JOY_BUTTON_DPAD_RIGHT)
	elif action == "move-up":
		_add_joy_btn(action, JOY_BUTTON_DPAD_UP)
	elif action == "move-down":
		_add_joy_btn(action, JOY_BUTTON_DPAD_DOWN)
	elif action == "detach":
		_add_joy_axis(action, JOY_AXIS_TRIGGER_LEFT, 1.0)
	elif action == "attack":
		_add_joy_axis(action, JOY_AXIS_TRIGGER_RIGHT, 1.0)

func _add_joy_btn(action: String, btn_index: int) -> void:
	var evt = InputEventJoypadButton.new()
	evt.button_index = btn_index
	InputMap.action_add_event(action, evt)

func _add_joy_axis(action: String, axis: int, val: float) -> void:
	var evt = InputEventJoypadMotion.new()
	evt.axis = axis
	evt.axis_value = val
	InputMap.action_add_event(action, evt)

func save_settings() -> void:
	ResourceSaver.save(settings_save, "user://settings.tres")

func get_settings() -> SettingsSave:
	return settings_save
