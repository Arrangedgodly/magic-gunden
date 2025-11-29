extends Node

var settings_save: SettingsSave

func _ready() -> void:
	load_and_apply_settings()

func load_and_apply_settings() -> void:
	var save_path = "user://settings.tres"
	
	if FileAccess.file_exists(save_path):
		settings_save = load(save_path) as SettingsSave
	
	if settings_save == null:
		settings_save = SettingsSave.new()
		if settings_save.control_mappings.is_empty():
			settings_save.set_default_controls()
		save_settings()
	
	apply_audio_settings()
	apply_control_mappings()

func apply_audio_settings() -> void:
	var music_db = linear_to_db(settings_save.music_volume / 100.0)
	var sfx_db = linear_to_db(settings_save.sfx_volume / 100.0)
	
	var music_bus_idx = AudioServer.get_bus_index("Music")
	var sfx_bus_idx = AudioServer.get_bus_index("SFX")
	
	if music_bus_idx >= 0:
		AudioServer.set_bus_volume_db(music_bus_idx, music_db)
	
	if sfx_bus_idx >= 0:
		AudioServer.set_bus_volume_db(sfx_bus_idx, sfx_db)

func apply_control_mappings() -> void:
	for action in settings_save.control_mappings.keys():
		
		if InputMap.has_action(action):
			InputMap.action_erase_events(action)
		
		if settings_save.control_mappings.has(action):
			var keycode = settings_save.control_mappings[action]
			var key_event = InputEventKey.new()
			key_event.physical_keycode = keycode
			InputMap.action_add_event(action, key_event)
			
		if settings_save.controller_buttons.has(action):
			var button_index = settings_save.controller_buttons[action]
			var joy_event = InputEventJoypadButton.new()
			joy_event.button_index = button_index
			InputMap.action_add_event(action, joy_event)
			
		if settings_save.controller_axes.has(action):
			var axis_data = settings_save.controller_axes[action]
			var joy_motion = InputEventJoypadMotion.new()
			joy_motion.axis = axis_data["axis"]
			joy_motion.axis_value = axis_data["value"]
			InputMap.action_add_event(action, joy_motion)

func save_settings() -> void:
	ResourceSaver.save(settings_save, "user://settings.tres")

func get_settings() -> SettingsSave:
	return settings_save
