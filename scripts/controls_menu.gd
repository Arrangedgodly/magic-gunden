extends Control

@onready var controls_list: VBoxContainer = %ControlsList
@onready var reset_controls_button: Button = %ResetControlsButton
@onready var back_button: Button = %BackButton
@onready var listening_label: Label = %ListeningLabel

var settings_save: SettingsSave
var currently_remapping: String = ""
var is_listening: bool = false
var remapping_is_controller: bool = false

var remappable_actions = [
	{"action": "move-up", "display": "Move Up"},
	{"action": "move-down", "display": "Move Down"},
	{"action": "move-left", "display": "Move Left"},
	{"action": "move-right", "display": "Move Right"},
	{"action": "aim-up", "display": "Aim Up"},
	{"action": "aim-down", "display": "Aim Down"},
	{"action": "aim-left", "display": "Aim Left"},
	{"action": "aim-right", "display": "Aim Right"},
	{"action": "attack", "display": "Attack/Shoot"},
	{"action": "detach", "display": "Detach Trail"},
	{"action": "menu", "display": "Pause Menu"},
	{"action": "ui_cancel", "display": "Cancel/Back"},
	{"action": "ui_accept", "display": "Accept/Confirm"}
]

signal controls_closed

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	load_settings()
	
	if listening_label:
		listening_label.hide()
	
	populate_controls()
	
	ControllerManager.controller_type_changed.connect(_on_controller_type_changed)
	ControllerManager.controller_connected.connect(_on_controller_connected)
	
	if reset_controls_button:
		reset_controls_button.pressed.connect(_on_reset_controls_pressed)
	if back_button:
		back_button.pressed.connect(_on_back_pressed)
		back_button.grab_focus()

func load_settings() -> void:
	settings_save = load("user://settings.tres") as SettingsSave
	if settings_save == null:
		settings_save = SettingsSave.new()
		settings_save.set_default_controls()

func save_settings() -> void:
	ResourceSaver.save(settings_save, "user://settings.tres")

func populate_controls() -> void:
	for child in controls_list.get_children():
		child.queue_free()
	
	for action_data in remappable_actions:
		create_control_entry(action_data["action"], action_data["display"])

func create_control_entry(action: String, display_name: String) -> void:
	var entry = HBoxContainer.new()
	entry.custom_minimum_size.x = 750
	
	var name_label = Label.new()
	name_label.text = display_name
	name_label.custom_minimum_size.x = 200
	entry.add_child(name_label)
	
	var keyboard_container = VBoxContainer.new()
	keyboard_container.custom_minimum_size.x = 250
	
	var kb_label = Label.new()
	kb_label.text = "Keyboard:"
	kb_label.add_theme_font_size_override("font_size", 16)
	keyboard_container.add_child(kb_label)
	
	var kb_display = HBoxContainer.new()
	var kb_glyph = get_keyboard_glyph_for_action(action)
	if kb_glyph:
		var glyph_texture = TextureRect.new()
		glyph_texture.texture = kb_glyph
		glyph_texture.custom_minimum_size = Vector2(32, 32)
		glyph_texture.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
		glyph_texture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		kb_display.add_child(glyph_texture)
	else:
		var kb_text = Label.new()
		kb_text.text = get_keyboard_name(action)
		kb_display.add_child(kb_text)
	
	var kb_button = Button.new()
	kb_button.text = "Change"
	kb_button.custom_minimum_size.x = 80
	kb_button.pressed.connect(_on_remap_button_pressed.bind(action, false))
	kb_display.add_child(kb_button)
	
	keyboard_container.add_child(kb_display)
	entry.add_child(keyboard_container)
	
	# Controller section
	var controller_container = VBoxContainer.new()
	controller_container.custom_minimum_size.x = 250
	
	var ctrl_label = Label.new()
	ctrl_label.text = "Controller:"
	ctrl_label.add_theme_font_size_override("font_size", 16)
	controller_container.add_child(ctrl_label)
	
	var ctrl_display = HBoxContainer.new()
	var ctrl_glyph = get_controller_glyph_for_action(action)
	if ctrl_glyph:
		var glyph_texture = TextureRect.new()
		glyph_texture.texture = ctrl_glyph
		glyph_texture.custom_minimum_size = Vector2(32, 32)
		glyph_texture.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
		glyph_texture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		ctrl_display.add_child(glyph_texture)
	else:
		var ctrl_text = Label.new()
		ctrl_text.text = get_controller_name(action)
		ctrl_display.add_child(ctrl_text)
	
	var ctrl_button = Button.new()
	ctrl_button.text = "Change"
	ctrl_button.custom_minimum_size.x = 80
	ctrl_button.pressed.connect(_on_remap_button_pressed.bind(action, true))
	ctrl_display.add_child(ctrl_button)
	
	controller_container.add_child(ctrl_display)
	entry.add_child(controller_container)
	
	controls_list.add_child(entry)

func get_keyboard_glyph_for_action(action: String) -> Texture2D:
	var events = InputMap.action_get_events(action)
	for event in events:
		if event is InputEventKey:
			return ControlDisplayData.get_keyboard_glyph(event.physical_keycode)
	return null

func get_controller_glyph_for_action(action: String) -> Texture2D:
	var events = InputMap.action_get_events(action)
	for event in events:
		if event is InputEventJoypadButton:
			return ControlDisplayData.get_controller_button_glyph(event.button_index)
		elif event is InputEventJoypadMotion:
			var axis_name = get_axis_name(event)
			if axis_name:
				return ControlDisplayData.get_controller_axis_glyph(axis_name)
	return null

func get_keyboard_name(action: String) -> String:
	var events = InputMap.action_get_events(action)
	for event in events:
		if event is InputEventKey:
			return OS.get_keycode_string(event.physical_keycode)
	return "Unbound"

func get_controller_name(action: String) -> String:
	var events = InputMap.action_get_events(action)
	for event in events:
		if event is InputEventJoypadButton:
			return "Button " + str(event.button_index)
		elif event is InputEventJoypadMotion:
			var axis_name = "Axis " + str(event.axis)
			if event.axis_value > 0:
				axis_name += " +"
			else:
				axis_name += " -"
			return axis_name
	return "Unbound"

func get_axis_name(event: InputEventJoypadMotion) -> String:
	match event.axis:
		JOY_AXIS_LEFT_X:
			return "left_stick_right" if event.axis_value > 0 else "left_stick_left"
		JOY_AXIS_LEFT_Y:
			return "left_stick_down" if event.axis_value > 0 else "left_stick_up"
		JOY_AXIS_RIGHT_X:
			return "right_stick_right" if event.axis_value > 0 else "right_stick_left"
		JOY_AXIS_RIGHT_Y:
			return "right_stick_down" if event.axis_value > 0 else "right_stick_up"
	return ""

func _on_remap_button_pressed(action: String, is_controller: bool) -> void:
	if is_listening:
		return
	
	currently_remapping = action
	remapping_is_controller = is_controller
	is_listening = true
	
	if listening_label:
		if is_controller:
			listening_label.text = "Press any button/axis for: " + action
		else:
			listening_label.text = "Press any key for: " + action
		listening_label.show()

func _input(event: InputEvent) -> void:
	if not is_listening:
		return
	
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		cancel_remapping()
		return
	
	if not remapping_is_controller and event is InputEventKey and event.pressed:
		var conflict = check_key_conflict(event.physical_keycode, currently_remapping)
		if conflict != "":
			cancel_remapping()
			return
		
		remap_keyboard_action(currently_remapping, event.physical_keycode)
		finish_remapping()
		
	elif remapping_is_controller and event is InputEventJoypadButton and event.pressed:
		var conflict = check_controller_button_conflict(event.button_index, currently_remapping)
		if conflict != "":
			cancel_remapping()
			return
		
		remap_controller_button_action(currently_remapping, event.button_index)
		finish_remapping()
		
	# Handle controller axis remapping
	elif remapping_is_controller and event is InputEventJoypadMotion:
		if abs(event.axis_value) > 0.5:  # Threshold to avoid drift
			var conflict = check_controller_axis_conflict(event.axis, event.axis_value, currently_remapping)
			if conflict != "":
				cancel_remapping()
				return
			
			remap_controller_axis_action(currently_remapping, event.axis, event.axis_value)
			finish_remapping()

func check_key_conflict(keycode: int, current_action: String) -> String:
	for action_data in remappable_actions:
		var action = action_data["action"]
		if action == current_action:
			continue
		
		var events = InputMap.action_get_events(action)
		for event in events:
			if event is InputEventKey:
				if event.physical_keycode == keycode:
					return action_data["display"]
	return ""

func check_controller_button_conflict(button: int, current_action: String) -> String:
	for action_data in remappable_actions:
		var action = action_data["action"]
		if action == current_action:
			continue
		
		var events = InputMap.action_get_events(action)
		for event in events:
			if event is InputEventJoypadButton:
				if event.button_index == button:
					return action_data["display"]
	return ""

func check_controller_axis_conflict(axis: int, axis_value: float, current_action: String) -> String:
	for action_data in remappable_actions:
		var action = action_data["action"]
		if action == current_action:
			continue
		
		var events = InputMap.action_get_events(action)
		for event in events:
			if event is InputEventJoypadMotion:
				if event.axis == axis and sign(event.axis_value) == sign(axis_value):
					return action_data["display"]
	return ""

func remap_keyboard_action(action: String, new_keycode: int) -> void:
	var events_to_keep = []
	for event in InputMap.action_get_events(action):
		if not event is InputEventKey:
			events_to_keep.append(event)
	
	InputMap.action_erase_events(action)
	for event in events_to_keep:
		InputMap.action_add_event(action, event)
	
	var new_event = InputEventKey.new()
	new_event.physical_keycode = new_keycode
	InputMap.action_add_event(action, new_event)
	
	settings_save.set_control_key(action, new_keycode)
	save_settings()

func remap_controller_button_action(action: String, new_button: int) -> void:
	var events_to_keep = []
	for event in InputMap.action_get_events(action):
		if not event is InputEventJoypadButton:
			events_to_keep.append(event)
	
	InputMap.action_erase_events(action)
	for event in events_to_keep:
		InputMap.action_add_event(action, event)
	
	var new_event = InputEventJoypadButton.new()
	new_event.button_index = new_button
	InputMap.action_add_event(action, new_event)
	
	settings_save.set_controller_button(action, new_button)
	save_settings()

func remap_controller_axis_action(action: String, axis: int, axis_value: float) -> void:
	var events_to_keep = []
	for event in InputMap.action_get_events(action):
		if not event is InputEventJoypadMotion:
			events_to_keep.append(event)
	
	InputMap.action_erase_events(action)
	for event in events_to_keep:
		InputMap.action_add_event(action, event)
	
	var new_event = InputEventJoypadMotion.new()
	new_event.axis = axis
	new_event.axis_value = sign(axis_value)
	InputMap.action_add_event(action, new_event)
	
	settings_save.set_controller_axis(action, axis, axis_value)
	save_settings()

func finish_remapping() -> void:
	populate_controls()
	is_listening = false
	currently_remapping = ""
	remapping_is_controller = false
	
	if listening_label:
		listening_label.hide()
	
	get_viewport().set_input_as_handled()

func cancel_remapping() -> void:
	is_listening = false
	currently_remapping = ""
	remapping_is_controller = false
	
	if listening_label:
		listening_label.hide()
	
	populate_controls()

func _on_reset_controls_pressed() -> void:
	settings_save.set_default_controls()
	
	for action_data in remappable_actions:
		var action = action_data["action"]
		var default_key = settings_save.get_control_key(action)
		
		if default_key != -1:
			InputMap.action_erase_events(action)
			var new_event = InputEventKey.new()
			new_event.physical_keycode = default_key
			InputMap.action_add_event(action, new_event)
	
	save_settings()
	populate_controls()

func _on_back_pressed() -> void:
	controls_closed.emit()
	queue_free()

func _on_controller_type_changed(_new_type: int) -> void:
	populate_controls()

func _on_controller_connected(_device_id: int, _controller_type: int) -> void:
	populate_controls()
