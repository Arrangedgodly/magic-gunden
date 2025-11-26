extends Resource
class_name SettingsSave

@export var music_volume: float = 80.0
@export var sfx_volume: float = 80.0
@export var master_volume: float = 100.0

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
		"aim-up": KEY_I,
		"aim-down": KEY_K,
		"aim-left": KEY_J,
		"aim-right": KEY_L,
		"attack": KEY_E,
		"detach": KEY_SPACE,
		"menu": KEY_ESCAPE,
		"ui_cancel": KEY_ESCAPE,
		"ui_accept": KEY_ENTER,
		"console": KEY_QUOTELEFT
	}

func get_control_key(action: String) -> int:
	if control_mappings.has(action):
		return control_mappings[action]
	return -1

func set_control_key(action: String, keycode: int) -> void:
	control_mappings[action] = keycode
