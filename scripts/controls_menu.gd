extends Control

@onready var controls_list: VBoxContainer = %ControlsList
@onready var reset_controls_button: Button = %ResetControlsButton
@onready var back_button: Button = %BackButton
@onready var listening_label: Label = %ListeningLabel

var settings_save: SettingsSave
var currently_remapping: String = ""
var is_listening: bool = false

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
	
	if reset_controls_button:
		reset_controls_button.pressed.connect(_on_reset_controls_pressed)
	if back_button:
		back_button.pressed.connect(_on_back_pressed)
		back_button.grab_focus()

func load_settings() -> void:
	settings_save = load("user://settings.tres") as SettingsSave
	if settings_save == null:
		settings_save = SettingsSave.new()

func save_settings() -> void:
	ResourceSaver.save(settings_save, "user://settings.tres")

func populate_controls() -> void:
	for child in controls_list.get_children():
		child.queue_free()
	
	for action_data in remappable_actions:
		create_control_entry(action_data["action"], action_data["display"])

func create_control_entry(action: String, display_name: String) -> void:
	var entry = HBoxContainer.new()
	entry.custom_minimum_size.x = 400
	
	var name_label = Label.new()
	name_label.text = display_name
	name_label.custom_minimum_size.x = 200
	entry.add_child(name_label)
	
	var key_button = Button.new()
	key_button.custom_minimum_size.x = 150
	key_button.text = get_key_name(action)
	key_button.pressed.connect(_on_remap_button_pressed.bind(action, key_button))
	entry.add_child(key_button)
	
	controls_list.add_child(entry)

func get_key_name(action: String) -> String:
	var events = InputMap.action_get_events(action)
	if events.size() > 0:
		var event = events[0]
		if event is InputEventKey:
			return OS.get_keycode_string(event.physical_keycode)
	return "Unbound"

func _on_remap_button_pressed(action: String, button: Button) -> void:
	if is_listening:
		return
	
	currently_remapping = action
	is_listening = true
	
	if listening_label:
		listening_label.text = "Press any key for: " + action
		listening_label.show()
	
	button.text = "..."

func _input(event: InputEvent) -> void:
	if not is_listening:
		return
	
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE:
			cancel_remapping()
			return
		
		var conflict = check_key_conflict(event.physical_keycode, currently_remapping)
		if conflict != "":
			cancel_remapping()
			return
		
		remap_action(currently_remapping, event.physical_keycode)
		
		populate_controls()
		
		is_listening = false
		currently_remapping = ""
		
		if listening_label:
			listening_label.hide()
		
		get_viewport().set_input_as_handled()

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

func remap_action(action: String, new_keycode: int) -> void:
	InputMap.action_erase_events(action)
	
	var new_event = InputEventKey.new()
	new_event.physical_keycode = new_keycode
	
	InputMap.action_add_event(action, new_event)
	
	settings_save.set_control_key(action, new_keycode)
	save_settings()

func cancel_remapping() -> void:
	is_listening = false
	currently_remapping = ""
	
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
