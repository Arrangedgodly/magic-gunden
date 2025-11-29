extends Resource
class_name SettingsSave

@export var music_volume: float = 80.0
@export var sfx_volume: float = 80.0
@export var master_volume: float = 100.0
@export var controller_buttons: Dictionary = {}
@export var controller_axes: Dictionary = {}
@export var control_mappings: Dictionary = {}

func _init() -> void:
	if music_volume == 0 and sfx_volume == 0:
		music_volume = 80.0
		sfx_volume = 80.0
		master_volume = 100.0
	
	if control_mappings.is_empty() or controller_buttons.is_empty():
		set_default_controls()

func set_default_controls() -> void:
	control_mappings.clear()
	controller_buttons.clear()
	controller_axes.clear()
	
	var actions_to_track = [
		"move-up", "move-down", "move-left", "move-right",
		"aim-up", "aim-down", "aim-left", "aim-right",
		"attack", "detach", "menu", "ui_cancel", "ui_accept", "console", 
		"ui_left", "ui_right", "ui_up", "ui_down"
	]
	
	for action in actions_to_track:
		if not InputMap.has_action(action):
			continue
			
		var events = InputMap.action_get_events(action)
		for event in events:
			if event is InputEventKey and not control_mappings.has(action):
				if event.physical_keycode > 0:
					control_mappings[action] = event.physical_keycode
				elif event.keycode > 0:
					control_mappings[action] = event.keycode
			
			elif event is InputEventJoypadButton and not controller_buttons.has(action):
				controller_buttons[action] = event.button_index
			
			elif event is InputEventJoypadMotion and not controller_axes.has(action):
				controller_axes[action] = {"axis": event.axis, "value": event.axis_value}

func get_control_key(action: String) -> int:
	return control_mappings.get(action, -1)

func set_control_key(action: String, keycode: int) -> void:
	control_mappings[action] = keycode

func set_controller_button(action: String, button: int) -> void:
	controller_buttons[action] = button

func get_controller_button(action: String) -> int:
	return controller_buttons.get(action, -1)

func set_controller_axis(action: String, axis: int, axis_value: float) -> void:
	controller_axes[action] = {"axis": axis, "value": axis_value}

func get_controller_axis(action: String) -> Dictionary:
	return controller_axes.get(action, {})
