extends Node

func _ready() -> void:
	initialize_input_map()

func initialize_input_map() -> void:
	var settings_save = load("user://settings.tres") as SettingsSave
	
	if settings_save == null:
		settings_save = SettingsSave.new()
		ResourceSaver.save(settings_save, "user://settings.tres")
		return
	
	apply_all_bindings(settings_save)

func populate_settings_from_input_map(settings_save: SettingsSave) -> void:
	var actions = [
		"move-up", "move-down", "move-left", "move-right",
		"aim-up", "aim-down", "aim-left", "aim-right",
		"attack", "detach", "menu", "ui_cancel", "ui_accept"
	]
	
	for action in actions:
		if not InputMap.has_action(action):
			continue
			
		var events = InputMap.action_get_events(action)
		
		for event in events:
			if event is InputEventKey:
				settings_save.set_control_key(action, event.physical_keycode)
			elif event is InputEventJoypadButton:
				settings_save.set_controller_button(action, event.button_index)
			elif event is InputEventJoypadMotion:
				settings_save.set_controller_axis(action, event.axis, event.axis_value)

func apply_all_bindings(settings_save: SettingsSave) -> void:
	for action in settings_save.control_mappings:
		var keycode = settings_save.control_mappings[action]
		if keycode != -1 and InputMap.has_action(action):
			var events_to_keep = []
			for event in InputMap.action_get_events(action):
				if not event is InputEventKey:
					events_to_keep.append(event)
			
			InputMap.action_erase_events(action)
			for event in events_to_keep:
				InputMap.action_add_event(action, event)
			
			var new_event = InputEventKey.new()
			new_event.physical_keycode = keycode
			InputMap.action_add_event(action, new_event)
	
	for action in settings_save.controller_buttons:
		var button = settings_save.controller_buttons[action]
		if button != -1 and InputMap.has_action(action):
			var events_to_keep = []
			for event in InputMap.action_get_events(action):
				if not event is InputEventJoypadButton:
					events_to_keep.append(event)
			
			InputMap.action_erase_events(action)
			for event in events_to_keep:
				InputMap.action_add_event(action, event)
			
			var new_event = InputEventJoypadButton.new()
			new_event.button_index = button
			InputMap.action_add_event(action, new_event)
	
	for action in settings_save.controller_axes:
		var axis_data = settings_save.controller_axes[action]
		if axis_data.has("axis") and InputMap.has_action(action):
			var events_to_keep = []
			for event in InputMap.action_get_events(action):
				if not event is InputEventJoypadMotion:
					events_to_keep.append(event)
			
			InputMap.action_erase_events(action)
			for event in events_to_keep:
				InputMap.action_add_event(action, event)
			
			# Add the saved controller axis binding
			var new_event = InputEventJoypadMotion.new()
			new_event.axis = axis_data["axis"]
			new_event.axis_value = axis_data["value"]
			InputMap.action_add_event(action, new_event)
