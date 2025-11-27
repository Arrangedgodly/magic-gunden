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
	
	if control_mappings.is_empty():
		set_default_controls()

func set_default_controls() -> void:
	control_mappings = {
		"move-up": KEY_W,
		"move-down": KEY_S,
		"move-left": KEY_A,
		"move-right": KEY_D,
		"aim-up": KEY_UP,
		"aim-down": KEY_DOWN,
		"aim-left": KEY_LEFT,
		"aim-right": KEY_RIGHT,
		"attack": KEY_SPACE,
		"detach": KEY_E,
		"menu": KEY_ESCAPE,
		"ui_cancel": KEY_ESCAPE,
		"ui_accept": KEY_ENTER,
		"console": KEY_QUOTELEFT
	}
	
	controller_buttons = {
		"attack": JOY_BUTTON_RIGHT_SHOULDER,
		"detach": JOY_BUTTON_LEFT_SHOULDER,
		"menu": JOY_BUTTON_START,
		"ui_cancel": JOY_BUTTON_B,
		"ui_accept": JOY_BUTTON_A
	}
	
	controller_axes = {
		"move-up": {"axis": JOY_AXIS_LEFT_Y, "value": -1.0},
		"move-down": {"axis": JOY_AXIS_LEFT_Y, "value": 1.0},
		"move-left": {"axis": JOY_AXIS_LEFT_X, "value": -1.0},
		"move-right": {"axis": JOY_AXIS_LEFT_X, "value": 1.0},
		"aim-up": {"axis": JOY_AXIS_RIGHT_Y, "value": -1.0},
		"aim-down": {"axis": JOY_AXIS_RIGHT_Y, "value": 1.0},
		"aim-left": {"axis": JOY_AXIS_RIGHT_X, "value": -1.0},
		"aim-right": {"axis": JOY_AXIS_RIGHT_X, "value": 1.0}
	}

func get_control_key(action: String) -> int:
	if control_mappings.has(action):
		return control_mappings[action]
	return -1

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
