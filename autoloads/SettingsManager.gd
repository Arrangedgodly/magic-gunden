extends Node

var settings_save: SettingsSave

func _ready() -> void:
	load_and_apply_settings()

func load_and_apply_settings() -> void:
	settings_save = load("user://settings.tres") as SettingsSave
	if settings_save == null:
		settings_save = SettingsSave.new()
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
		var keycode = settings_save.control_mappings[action]
		
		if InputMap.has_action(action):
			InputMap.action_erase_events(action)
			
			var new_event = InputEventKey.new()
			new_event.physical_keycode = keycode
			InputMap.action_add_event(action, new_event)

func linear_to_db(linear: float) -> float:
	if linear <= 0:
		return -80.0
	return 20.0 * log(linear) / log(10.0)

func save_settings() -> void:
	ResourceSaver.save(settings_save, "user://settings.tres")

func get_settings() -> SettingsSave:
	return settings_save
