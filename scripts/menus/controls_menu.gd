extends Control

@onready var controls_list: GridContainer = %ControlsList
@onready var reset_controls_button: Button = %ResetControlsButton
@onready var back_button: Button = %BackButton
@onready var listening_label: Label = %ListeningLabel

var control_entry_scene = preload("res://scenes/menus/control_entry.tscn")

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
	DebugLogger.log_info("=== CONTROLS MENU READY START ===")
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	load_settings()
	
	if listening_label:
		listening_label.hide()
	
	ControllerManager.controller_type_changed.connect(_on_controller_type_changed)
	ControllerManager.controller_connected.connect(_on_controller_connected)
	
	populate_controls()
	
	if reset_controls_button:
		reset_controls_button.pressed.connect(_on_reset_controls_pressed)
	if back_button:
		back_button.pressed.connect(_on_back_pressed)
		back_button.grab_focus()
	
	DebugLogger.log_info("=== CONTROLS MENU READY COMPLETE ===")

func load_settings() -> void:
	settings_save = SaveHelper.load_settings()

func save_settings() -> void:
	SaveHelper.save_settings(settings_save)

func populate_controls() -> void:
	DebugLogger.log_info("Populating controls...")
	for child in controls_list.get_children():
		child.queue_free()
	
	var current_type = ControllerManager.get_controller_type()
	var is_controller_mode = current_type != ControllerManager.ControllerType.KEYBOARD
	
	for action_data in remappable_actions:
		var entry = control_entry_scene.instantiate()
		controls_list.add_child(entry)
		
		entry.setup(action_data["action"], action_data["display"], is_controller_mode)
		
		entry.remap_requested.connect(_on_remap_requested.bind(is_controller_mode))
	
	DebugLogger.log_info("Controls populated")

func _on_remap_requested(action: String, is_controller: bool) -> void:
	DebugLogger.log_info("Remap request initiated...")
	if is_listening:
		return
	
	currently_remapping = action
	remapping_is_controller = is_controller
	is_listening = true
	
	if listening_label:
		var input_type = "button" if is_controller else "key"
		listening_label.text = "Press %s for: %s" % [input_type, action]
		listening_label.show()
	
	DebugLogger.log_info("Remap request complete")

func populate_keyboard_inputs(container: Container, action: String) -> int:
	DebugLogger.log_info("Populating keyboard controls...")
	var events = InputMap.action_get_events(action)
	var count = 0
	
	for event in events:
		if event is InputEventKey:
			add_input_icon(container, event)
			count += 1
	
	DebugLogger.log_info("Keyboard controls populated")
	return count

func populate_controller_inputs(container: Container, action: String) -> int:
	DebugLogger.log_info("Populating controller controls...")
	var events = InputMap.action_get_events(action)
	var count = 0
	
	for event in events:
		if event is InputEventJoypadButton or event is InputEventJoypadMotion:
			add_input_icon(container, event)
			count += 1
	
	DebugLogger.log_info("Controller controls populated")
	return count

func add_input_icon(container: Container, event: InputEvent) -> void:
	var glyph: Texture2D = null
	var text_fallback: String = ""
	
	if event is InputEventKey:
		glyph = ControlDisplayData.get_keyboard_glyph(event.physical_keycode)
		if not glyph:
			text_fallback = OS.get_keycode_string(event.physical_keycode)
			
	elif event is InputEventJoypadButton:
		glyph = ControlDisplayData.get_controller_button_glyph(event.button_index)
		if not glyph:
			text_fallback = "Btn " + str(event.button_index)
			
	elif event is InputEventJoypadMotion:
		var axis_name = get_axis_name(event)
		if axis_name:
			glyph = ControlDisplayData.get_controller_axis_glyph(axis_name)
		if not glyph:
			text_fallback = "Axis " + str(event.axis)

	if glyph:
		var texture_rect = TextureRect.new()
		texture_rect.texture = glyph
		texture_rect.custom_minimum_size = Vector2(40, 40)
		texture_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
		texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		container.add_child(texture_rect)
	else:
		var panel = PanelContainer.new()
		var lbl = Label.new()
		lbl.text = text_fallback
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		panel.add_child(lbl)
		container.add_child(panel)

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
			listening_label.text = "Press button for: " + action
		else:
			listening_label.text = "Press key for: " + action
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

	elif remapping_is_controller and event is InputEventJoypadMotion:
		if abs(event.axis_value) > 0.5:
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
			remap_keyboard_action(action, default_key)
			
		var default_button = settings_save.get_controller_button(action)
		if default_button != -1:
			remap_controller_button_action(action, default_button)
			
		var axis_data = settings_save.get_controller_axis(action)
		if not axis_data.is_empty():
			remap_controller_axis_action(action, axis_data["axis"], axis_data["value"])
	
	save_settings()
	populate_controls() 

func _on_back_pressed() -> void:
	controls_closed.emit()
	queue_free()

func _on_controller_type_changed(_new_type: int) -> void:
	populate_controls()

func _on_controller_connected(_device_id: int, _controller_type: int) -> void:
	populate_controls()
