class_name ControlDisplayData
extends Resource

const KEYBOARD_GLYPHS = {
	KEY_W: "res://assets/UI/kenney_input-prompts/Keyboard & Mouse/Double/keyboard_w.png",
	KEY_A: "res://assets/UI/kenney_input-prompts/Keyboard & Mouse/Double/keyboard_a.png",
	KEY_S: "res://assets/UI/kenney_input-prompts/Keyboard & Mouse/Double/keyboard_s.png",
	KEY_D: "res://assets/UI/kenney_input-prompts/Keyboard & Mouse/Double/keyboard_d.png",
	KEY_UP: "res://assets/UI/kenney_input-prompts/Keyboard & Mouse/Double/keyboard_arrow_up.png",
	KEY_DOWN: "res://assets/UI/kenney_input-prompts/Keyboard & Mouse/Double/keyboard_arrow_down.png",
	KEY_LEFT: "res://assets/UI/kenney_input-prompts/Keyboard & Mouse/Double/keyboard_arrow_left.png",
	KEY_RIGHT: "res://assets/UI/kenney_input-prompts/Keyboard & Mouse/Double/keyboard_arrow_right.png",
	KEY_SPACE: "res://assets/UI/kenney_input-prompts/Keyboard & Mouse/Double/keyboard_space.png",
	KEY_E: "res://assets/UI/kenney_input-prompts/Keyboard & Mouse/Double/keyboard_e.png",
	KEY_ESCAPE: "res://assets/UI/kenney_input-prompts/Keyboard & Mouse/Double/keyboard_escape.png",
	KEY_ENTER: "res://assets/UI/kenney_input-prompts/Keyboard & Mouse/Double/keyboard_enter.png",
	# Add more as needed
}

const STEAM_DECK_GLYPHS = {
	JOY_BUTTON_A: "res://assets/UI/kenney_input-prompts/Steam Deck/Double/steamdeck_button_a.png",
	JOY_BUTTON_B: "res://assets/UI/kenney_input-prompts/Steam Deck/Double/steamdeck_button_b.png",
	JOY_BUTTON_X: "res://assets/UI/kenney_input-prompts/Steam Deck/Double/steamdeck_button_x.png",
	JOY_BUTTON_Y: "res://assets/UI/kenney_input-prompts/Steam Deck/Double/steamdeck_button_y.png",
	JOY_BUTTON_LEFT_SHOULDER: "res://assets/UI/kenney_input-prompts/Steam Deck/Double/steamdeck_button_l1.png",
	JOY_BUTTON_RIGHT_SHOULDER: "res://assets/UI/kenney_input-prompts/Steam Deck/Double/steamdeck_button_r1.png",
	JOY_BUTTON_START: "res://assets/UI/kenney_input-prompts/Steam Deck/Double/steamdeck_button_options.png",
	JOY_BUTTON_BACK: "res://assets/UI/kenney_input-prompts/Steam Deck/Double/steamdeck_button_b.png",
	JOY_BUTTON_DPAD_UP: "res://assets/UI/kenney_input-prompts/Steam Deck/Double/steamdeck_dpad_up.png",
	JOY_BUTTON_DPAD_DOWN: "res://assets/UI/kenney_input-prompts/Steam Deck/Double/steamdeck_dpad_down.png",
	JOY_BUTTON_DPAD_LEFT: "res://assets/UI/kenney_input-prompts/Steam Deck/Double/steamdeck_dpad_left.png",
	JOY_BUTTON_DPAD_RIGHT: "res://assets/UI/kenney_input-prompts/Steam Deck/Double/steamdeck_dpad_right.png",
	JOY_BUTTON_LEFT_STICK: "res://assets/UI/kenney_input-prompts/Steam Deck/Double/steamdeck_stick_l.png",
	JOY_BUTTON_RIGHT_STICK: "res://assets/UI/kenney_input-prompts/Steam Deck/Double/steamdeck_stick_r.png"
}

const XBOX_GLYPHS = {
	JOY_BUTTON_A: "res://assets/UI/kenney_input-prompts/Xbox Series/Double/xbox_button_a.png",
	JOY_BUTTON_B: "res://assets/UI/kenney_input-prompts/Xbox Series/Double/xbox_button_b.png",
	JOY_BUTTON_X: "res://assets/UI/kenney_input-prompts/Xbox Series/Double/xbox_button_x.png",
	JOY_BUTTON_Y: "res://assets/UI/kenney_input-prompts/Xbox Series/Double/xbox_button_y.png",
	JOY_BUTTON_LEFT_SHOULDER: "res://assets/UI/kenney_input-prompts/Xbox Series/Double/xbox_lb.png",
	JOY_BUTTON_RIGHT_SHOULDER: "res://assets/UI/kenney_input-prompts/Xbox Series/Double/xbox_rb.png",
	JOY_BUTTON_START: "res://assets/UI/kenney_input-prompts/Xbox Series/Double/xbox_button_start.png",
	JOY_BUTTON_BACK: "res://assets/UI/kenney_input-prompts/Xbox Series/Double/xbox_button_b.png",
	JOY_BUTTON_DPAD_UP: "res://assets/UI/kenney_input-prompts/Xbox Series/Double/xbox_dpad_up.png",
	JOY_BUTTON_DPAD_DOWN: "res://assets/UI/kenney_input-prompts/Xbox Series/Double/xbox_dpad_down.png",
	JOY_BUTTON_DPAD_LEFT: "res://assets/UI/kenney_input-prompts/Xbox Series/Double/xbox_dpad_left.png",
	JOY_BUTTON_DPAD_RIGHT: "res://assets/UI/kenney_input-prompts/Xbox Series/Double/xbox_dpad_right.png",
	# Add more as needed
}

const PLAYSTATION_GLYPHS = {
	JOY_BUTTON_A: "res://assets/UI/kenney_input-prompts/PlayStation Series/Double/playstation_button_cross.png",
	JOY_BUTTON_B: "res://assets/UI/kenney_input-prompts/PlayStation Series/Double/playstation_button_circle.png",
	JOY_BUTTON_X: "res://assets/UI/kenney_input-prompts/PlayStation Series/Double/playstation_button_square.png",
	JOY_BUTTON_Y: "res://assets/UI/kenney_input-prompts/PlayStation Series/Double/playstation_button_triangle.png",
	JOY_BUTTON_LEFT_SHOULDER: "res://assets/UI/kenney_input-prompts/PlayStation Series/Double/playstation_trigger_l1.png",
	JOY_BUTTON_RIGHT_SHOULDER: "res://assets/UI/kenney_input-prompts/PlayStation Series/Double/playstation_trigger_r1.png",
	JOY_BUTTON_START: "res://assets/UI/kenney_input-prompts/PlayStation Series/Double/playstation3_button_start.png",
	JOY_BUTTON_BACK: "res://assets/UI/kenney_input-prompts/PlayStation Series/Double/playstation_button_circle.png",
	JOY_BUTTON_DPAD_UP: "res://assets/UI/kenney_input-prompts/PlayStation Series/Double/playstation_dpad_up.png",
	JOY_BUTTON_DPAD_DOWN: "res://assets/UI/kenney_input-prompts/PlayStation Series/Double/playstation_dpad_down.png",
	JOY_BUTTON_DPAD_LEFT: "res://assets/UI/kenney_input-prompts/PlayStation Series/Double/playstation_dpad_left.png",
	JOY_BUTTON_DPAD_RIGHT: "res://assets/UI/kenney_input-prompts/PlayStation Series/Double/playstation_dpad_right.png",
	# Add more as needed
}

const CONTROLLER_AXIS_GLYPHS = {
	"left_stick_up": "res://assets/UI/kenney_input-prompts/PlayStation Series/Double/playstation_stick_l_up.png",
	"left_stick_down": "res://assets/UI/kenney_input-prompts/PlayStation Series/Double/playstation_stick_l_down.png",
	"left_stick_left": "res://assets/UI/kenney_input-prompts/PlayStation Series/Double/playstation_stick_l_left.png",
	"left_stick_right": "res://assets/UI/kenney_input-prompts/PlayStation Series/Double/playstation_stick_l_right.png",
	"right_stick_up": "res://assets/UI/kenney_input-prompts/PlayStation Series/Double/playstation_stick_r_up.png",
	"right_stick_down": "res://assets/UI/kenney_input-prompts/PlayStation Series/Double/playstation_stick_r_down.png",
	"right_stick_left": "res://assets/UI/kenney_input-prompts/PlayStation Series/Double/playstation_stick_r_left.png",
	"right_stick_right": "res://assets/UI/kenney_input-prompts/PlayStation Series/Double/playstation_stick_r_right.png",
}

static func get_keyboard_glyph(keycode: int) -> Texture2D:
	var path = KEYBOARD_GLYPHS.get(keycode, "")
	if path and FileAccess.file_exists(path):
		return load(path)
	return null

static func get_controller_button_glyph(button: int, controller_type = null) -> Texture2D:
	if controller_type == null:
		controller_type = ControllerManager.get_controller_type()
	
	var glyph_set = _get_button_glyph_set(controller_type)
	var path = glyph_set.get(button, "")
	
	if path and FileAccess.file_exists(path):
		return load(path)
	
	if controller_type != ControllerManager.ControllerType.XBOX:
		path = XBOX_GLYPHS.get(button, "")
		if path and FileAccess.file_exists(path):
			return load(path)
	
	return null

static func get_controller_axis_glyph(axis_name: String, _controller_type = null) -> Texture2D:
	var path = CONTROLLER_AXIS_GLYPHS.get(axis_name, "")
	
	if path and FileAccess.file_exists(path):
		return load(path)
	
	return null

static func _get_button_glyph_set(controller_type) -> Dictionary:
	match controller_type:
		ControllerManager.ControllerType.PLAYSTATION:
			return PLAYSTATION_GLYPHS
		ControllerManager.ControllerType.STEAM_DECK:
			return STEAM_DECK_GLYPHS
		_:
			return XBOX_GLYPHS
