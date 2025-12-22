class_name ControlDisplayData
extends Resource

const KEYBOARD_GLYPHS = {
	KEY_A: "res://assets/UI/kenney_input-prompts/Keyboard & Mouse/Double/keyboard_a.png",
	KEY_B: "res://assets/UI/kenney_input-prompts/Keyboard & Mouse/Double/keyboard_b.png",
	KEY_C: "res://assets/UI/kenney_input-prompts/Keyboard & Mouse/Double/keyboard_c.png",
	KEY_D: "res://assets/UI/kenney_input-prompts/Keyboard & Mouse/Double/keyboard_d.png",
	KEY_E: "res://assets/UI/kenney_input-prompts/Keyboard & Mouse/Double/keyboard_e.png",
	KEY_F: "res://assets/UI/kenney_input-prompts/Keyboard & Mouse/Double/keyboard_f.png",
	KEY_G: "res://assets/UI/kenney_input-prompts/Keyboard & Mouse/Double/keyboard_g.png",
	KEY_H: "res://assets/UI/kenney_input-prompts/Keyboard & Mouse/Double/keyboard_h.png",
	KEY_I: "res://assets/UI/kenney_input-prompts/Keyboard & Mouse/Double/keyboard_i.png",
	KEY_J: "res://assets/UI/kenney_input-prompts/Keyboard & Mouse/Double/keyboard_j.png",
	KEY_K: "res://assets/UI/kenney_input-prompts/Keyboard & Mouse/Double/keyboard_k.png",
	KEY_L: "res://assets/UI/kenney_input-prompts/Keyboard & Mouse/Double/keyboard_l.png",
	KEY_M: "res://assets/UI/kenney_input-prompts/Keyboard & Mouse/Double/keyboard_m.png",
	KEY_N: "res://assets/UI/kenney_input-prompts/Keyboard & Mouse/Double/keyboard_n.png",
	KEY_O: "res://assets/UI/kenney_input-prompts/Keyboard & Mouse/Double/keyboard_o.png",
	KEY_P: "res://assets/UI/kenney_input-prompts/Keyboard & Mouse/Double/keyboard_p.png",
	KEY_Q: "res://assets/UI/kenney_input-prompts/Keyboard & Mouse/Double/keyboard_q.png",
	KEY_R: "res://assets/UI/kenney_input-prompts/Keyboard & Mouse/Double/keyboard_r.png",
	KEY_S: "res://assets/UI/kenney_input-prompts/Keyboard & Mouse/Double/keyboard_s.png",
	KEY_T: "res://assets/UI/kenney_input-prompts/Keyboard & Mouse/Double/keyboard_t.png",
	KEY_U: "res://assets/UI/kenney_input-prompts/Keyboard & Mouse/Double/keyboard_u.png",
	KEY_V: "res://assets/UI/kenney_input-prompts/Keyboard & Mouse/Double/keyboard_v.png",
	KEY_W: "res://assets/UI/kenney_input-prompts/Keyboard & Mouse/Double/keyboard_w.png",
	KEY_X: "res://assets/UI/kenney_input-prompts/Keyboard & Mouse/Double/keyboard_x.png",
	KEY_Y: "res://assets/UI/kenney_input-prompts/Keyboard & Mouse/Double/keyboard_y.png",
	KEY_Z: "res://assets/UI/kenney_input-prompts/Keyboard & Mouse/Double/keyboard_z.png",
	KEY_0: "res://assets/UI/kenney_input-prompts/Keyboard & Mouse/Double/keyboard_0.png",
	KEY_1: "res://assets/UI/kenney_input-prompts/Keyboard & Mouse/Double/keyboard_1.png",
	KEY_2: "res://assets/UI/kenney_input-prompts/Keyboard & Mouse/Double/keyboard_2.png",
	KEY_3: "res://assets/UI/kenney_input-prompts/Keyboard & Mouse/Double/keyboard_3.png",
	KEY_4: "res://assets/UI/kenney_input-prompts/Keyboard & Mouse/Double/keyboard_4.png",
	KEY_5: "res://assets/UI/kenney_input-prompts/Keyboard & Mouse/Double/keyboard_5.png",
	KEY_6: "res://assets/UI/kenney_input-prompts/Keyboard & Mouse/Double/keyboard_6.png",
	KEY_7: "res://assets/UI/kenney_input-prompts/Keyboard & Mouse/Double/keyboard_7.png",
	KEY_8: "res://assets/UI/kenney_input-prompts/Keyboard & Mouse/Double/keyboard_8.png",
	KEY_9: "res://assets/UI/kenney_input-prompts/Keyboard & Mouse/Double/keyboard_9.png",
	KEY_F1: "res://assets/UI/kenney_input-prompts/Keyboard & Mouse/Double/keyboard_f1.png",
	KEY_F2: "res://assets/UI/kenney_input-prompts/Keyboard & Mouse/Double/keyboard_f2.png",
	KEY_F3: "res://assets/UI/kenney_input-prompts/Keyboard & Mouse/Double/keyboard_f3.png",
	KEY_F4: "res://assets/UI/kenney_input-prompts/Keyboard & Mouse/Double/keyboard_f4.png",
	KEY_F5: "res://assets/UI/kenney_input-prompts/Keyboard & Mouse/Double/keyboard_f5.png",
	KEY_F6: "res://assets/UI/kenney_input-prompts/Keyboard & Mouse/Double/keyboard_f6.png",
	KEY_F7: "res://assets/UI/kenney_input-prompts/Keyboard & Mouse/Double/keyboard_f7.png",
	KEY_F8: "res://assets/UI/kenney_input-prompts/Keyboard & Mouse/Double/keyboard_f8.png",
	KEY_F9: "res://assets/UI/kenney_input-prompts/Keyboard & Mouse/Double/keyboard_f9.png",
	KEY_F10: "res://assets/UI/kenney_input-prompts/Keyboard & Mouse/Double/keyboard_f10.png",
	KEY_F11: "res://assets/UI/kenney_input-prompts/Keyboard & Mouse/Double/keyboard_f11.png",
	KEY_F12: "res://assets/UI/kenney_input-prompts/Keyboard & Mouse/Double/keyboard_f12.png",
	KEY_UP: "res://assets/UI/kenney_input-prompts/Keyboard & Mouse/Double/keyboard_arrow_up.png",
	KEY_DOWN: "res://assets/UI/kenney_input-prompts/Keyboard & Mouse/Double/keyboard_arrow_down.png",
	KEY_LEFT: "res://assets/UI/kenney_input-prompts/Keyboard & Mouse/Double/keyboard_arrow_left.png",
	KEY_RIGHT: "res://assets/UI/kenney_input-prompts/Keyboard & Mouse/Double/keyboard_arrow_right.png",
	KEY_SPACE: "res://assets/UI/kenney_input-prompts/Keyboard & Mouse/Double/keyboard_space.png",
	KEY_ENTER: "res://assets/UI/kenney_input-prompts/Keyboard & Mouse/Double/keyboard_enter.png",
	KEY_ESCAPE: "res://assets/UI/kenney_input-prompts/Keyboard & Mouse/Double/keyboard_escape.png",
	KEY_BACKSPACE: "res://assets/UI/kenney_input-prompts/Keyboard & Mouse/Double/keyboard_backspace.png",
	KEY_TAB: "res://assets/UI/kenney_input-prompts/Keyboard & Mouse/Double/keyboard_tab.png",
	KEY_SHIFT: "res://assets/UI/kenney_input-prompts/Keyboard & Mouse/Double/keyboard_shift.png",
	KEY_CTRL: "res://assets/UI/kenney_input-prompts/Keyboard & Mouse/Double/keyboard_ctrl.png",
	KEY_ALT: "res://assets/UI/kenney_input-prompts/Keyboard & Mouse/Double/keyboard_alt.png",
	KEY_QUOTELEFT: "res://assets/UI/kenney_input-prompts/Keyboard & Mouse/Double/keyboard_tilde.png",
}

const XBOX_GLYPHS = {
	JOY_BUTTON_A: "res://assets/UI/kenney_input-prompts/Xbox Series/Double/xbox_button_a.png",
	JOY_BUTTON_B: "res://assets/UI/kenney_input-prompts/Xbox Series/Double/xbox_button_b.png",
	JOY_BUTTON_X: "res://assets/UI/kenney_input-prompts/Xbox Series/Double/xbox_button_x.png",
	JOY_BUTTON_Y: "res://assets/UI/kenney_input-prompts/Xbox Series/Double/xbox_button_y.png",
	JOY_BUTTON_LEFT_SHOULDER: "res://assets/UI/kenney_input-prompts/Xbox Series/Double/xbox_lb.png",
	JOY_BUTTON_RIGHT_SHOULDER: "res://assets/UI/kenney_input-prompts/Xbox Series/Double/xbox_rb.png",
	JOY_BUTTON_START: "res://assets/UI/kenney_input-prompts/Xbox Series/Double/xbox_button_menu.png",
	JOY_BUTTON_BACK: "res://assets/UI/kenney_input-prompts/Xbox Series/Double/xbox_button_view.png",
	JOY_BUTTON_DPAD_UP: "res://assets/UI/kenney_input-prompts/Xbox Series/Double/xbox_dpad_up.png",
	JOY_BUTTON_DPAD_DOWN: "res://assets/UI/kenney_input-prompts/Xbox Series/Double/xbox_dpad_down.png",
	JOY_BUTTON_DPAD_LEFT: "res://assets/UI/kenney_input-prompts/Xbox Series/Double/xbox_dpad_left.png",
	JOY_BUTTON_DPAD_RIGHT: "res://assets/UI/kenney_input-prompts/Xbox Series/Double/xbox_dpad_right.png",
	JOY_BUTTON_LEFT_STICK: "res://assets/UI/kenney_input-prompts/Xbox Series/Double/xbox_stick_l_click.png",
	JOY_BUTTON_RIGHT_STICK: "res://assets/UI/kenney_input-prompts/Xbox Series/Double/xbox_stick_r_click.png",
}

const PLAYSTATION_GLYPHS = {
	JOY_BUTTON_A: "res://assets/UI/kenney_input-prompts/PlayStation Series/Double/playstation_button_cross.png",
	JOY_BUTTON_B: "res://assets/UI/kenney_input-prompts/PlayStation Series/Double/playstation_button_circle.png",
	JOY_BUTTON_X: "res://assets/UI/kenney_input-prompts/PlayStation Series/Double/playstation_button_square.png",
	JOY_BUTTON_Y: "res://assets/UI/kenney_input-prompts/PlayStation Series/Double/playstation_button_triangle.png",
	JOY_BUTTON_LEFT_SHOULDER: "res://assets/UI/kenney_input-prompts/PlayStation Series/Double/playstation_trigger_l1.png",
	JOY_BUTTON_RIGHT_SHOULDER: "res://assets/UI/kenney_input-prompts/PlayStation Series/Double/playstation_trigger_r1.png",
	JOY_BUTTON_START: "res://assets/UI/kenney_input-prompts/PlayStation Series/Double/playstation_button_start.png",
	JOY_BUTTON_BACK: "res://assets/UI/kenney_input-prompts/PlayStation Series/Double/playstation_button_select.png",
	JOY_BUTTON_DPAD_UP: "res://assets/UI/kenney_input-prompts/PlayStation Series/Double/playstation_dpad_up.png",
	JOY_BUTTON_DPAD_DOWN: "res://assets/UI/kenney_input-prompts/PlayStation Series/Double/playstation_dpad_down.png",
	JOY_BUTTON_DPAD_LEFT: "res://assets/UI/kenney_input-prompts/PlayStation Series/Double/playstation_dpad_left.png",
	JOY_BUTTON_DPAD_RIGHT: "res://assets/UI/kenney_input-prompts/PlayStation Series/Double/playstation_dpad_right.png",
	JOY_BUTTON_LEFT_STICK: "res://assets/UI/kenney_input-prompts/PlayStation Series/Double/playstation_stick_l_click.png",
	JOY_BUTTON_RIGHT_STICK: "res://assets/UI/kenney_input-prompts/PlayStation Series/Double/playstation_stick_r_click.png",
}

const STEAM_DECK_GLYPHS = {
	JOY_BUTTON_A: "res://assets/UI/kenney_input-prompts/Steam Deck/Double/steamdeck_button_a.png",
	JOY_BUTTON_B: "res://assets/UI/kenney_input-prompts/Steam Deck/Double/steamdeck_button_b.png",
	JOY_BUTTON_X: "res://assets/UI/kenney_input-prompts/Steam Deck/Double/steamdeck_button_x.png",
	JOY_BUTTON_Y: "res://assets/UI/kenney_input-prompts/Steam Deck/Double/steamdeck_button_y.png",
	JOY_BUTTON_LEFT_SHOULDER: "res://assets/UI/kenney_input-prompts/Steam Deck/Double/steamdeck_button_l1.png",
	JOY_BUTTON_RIGHT_SHOULDER: "res://assets/UI/kenney_input-prompts/Steam Deck/Double/steamdeck_button_r1.png",
	JOY_BUTTON_START: "res://assets/UI/kenney_input-prompts/Steam Deck/Double/steamdeck_button_menu.png",
	JOY_BUTTON_BACK: "res://assets/UI/kenney_input-prompts/Steam Deck/Double/steamdeck_button_view.png",
	JOY_BUTTON_DPAD_UP: "res://assets/UI/kenney_input-prompts/Steam Deck/Double/steamdeck_dpad_up.png",
	JOY_BUTTON_DPAD_DOWN: "res://assets/UI/kenney_input-prompts/Steam Deck/Double/steamdeck_dpad_down.png",
	JOY_BUTTON_DPAD_LEFT: "res://assets/UI/kenney_input-prompts/Steam Deck/Double/steamdeck_dpad_left.png",
	JOY_BUTTON_DPAD_RIGHT: "res://assets/UI/kenney_input-prompts/Steam Deck/Double/steamdeck_dpad_right.png",
	JOY_BUTTON_LEFT_STICK: "res://assets/UI/kenney_input-prompts/Steam Deck/Double/steamdeck_stick_l_click.png",
	JOY_BUTTON_RIGHT_STICK: "res://assets/UI/kenney_input-prompts/Steam Deck/Double/steamdeck_stick_r_click.png",
}

const XBOX_AXIS_GLYPHS = {
	"left_stick_up": "res://assets/UI/kenney_input-prompts/Xbox Series/Double/xbox_stick_l_up.png",
	"left_stick_down": "res://assets/UI/kenney_input-prompts/Xbox Series/Double/xbox_stick_l_down.png",
	"left_stick_left": "res://assets/UI/kenney_input-prompts/Xbox Series/Double/xbox_stick_l_left.png",
	"left_stick_right": "res://assets/UI/kenney_input-prompts/Xbox Series/Double/xbox_stick_l_right.png",
	"right_stick_up": "res://assets/UI/kenney_input-prompts/Xbox Series/Double/xbox_stick_r_up.png",
	"right_stick_down": "res://assets/UI/kenney_input-prompts/Xbox Series/Double/xbox_stick_r_down.png",
	"right_stick_left": "res://assets/UI/kenney_input-prompts/Xbox Series/Double/xbox_stick_r_left.png",
	"right_stick_right": "res://assets/UI/kenney_input-prompts/Xbox Series/Double/xbox_stick_r_right.png",
	"trigger_left": "res://assets/UI/kenney_input-prompts/Xbox Series/Double/xbox_lt.png",
	"trigger_right": "res://assets/UI/kenney_input-prompts/Xbox Series/Double/xbox_rt.png",
}

const PLAYSTATION_AXIS_GLYPHS = {
	"left_stick_up": "res://assets/UI/kenney_input-prompts/PlayStation Series/Double/playstation_stick_l_up.png",
	"left_stick_down": "res://assets/UI/kenney_input-prompts/PlayStation Series/Double/playstation_stick_l_down.png",
	"left_stick_left": "res://assets/UI/kenney_input-prompts/PlayStation Series/Double/playstation_stick_l_left.png",
	"left_stick_right": "res://assets/UI/kenney_input-prompts/PlayStation Series/Double/playstation_stick_l_right.png",
	"right_stick_up": "res://assets/UI/kenney_input-prompts/PlayStation Series/Double/playstation_stick_r_up.png",
	"right_stick_down": "res://assets/UI/kenney_input-prompts/PlayStation Series/Double/playstation_stick_r_down.png",
	"right_stick_left": "res://assets/UI/kenney_input-prompts/PlayStation Series/Double/playstation_stick_r_left.png",
	"right_stick_right": "res://assets/UI/kenney_input-prompts/PlayStation Series/Double/playstation_stick_r_right.png",
	"trigger_left": "res://assets/UI/kenney_input-prompts/PlayStation Series/Double/playstation_trigger_l2.png",
	"trigger_right": "res://assets/UI/kenney_input-prompts/PlayStation Series/Double/playstation_trigger_r2.png",
}

const STEAM_DECK_AXIS_GLYPHS = {
	"left_stick_up": "res://assets/UI/kenney_input-prompts/Steam Deck/Double/steamdeck_stick_l_up.png",
	"left_stick_down": "res://assets/UI/kenney_input-prompts/Steam Deck/Double/steamdeck_stick_l_down.png",
	"left_stick_left": "res://assets/UI/kenney_input-prompts/Steam Deck/Double/steamdeck_stick_l_left.png",
	"left_stick_right": "res://assets/UI/kenney_input-prompts/Steam Deck/Double/steamdeck_stick_l_right.png",
	"right_stick_up": "res://assets/UI/kenney_input-prompts/Steam Deck/Double/steamdeck_stick_r_up.png",
	"right_stick_down": "res://assets/UI/kenney_input-prompts/Steam Deck/Double/steamdeck_stick_r_down.png",
	"right_stick_left": "res://assets/UI/kenney_input-prompts/Steam Deck/Double/steamdeck_stick_r_left.png",
	"right_stick_right": "res://assets/UI/kenney_input-prompts/Steam Deck/Double/steamdeck_stick_r_right.png",
	"trigger_left": "res://assets/UI/kenney_input-prompts/Steam Deck/Double/steamdeck_trigger_l2.png",
	"trigger_right": "res://assets/UI/kenney_input-prompts/Steam Deck/Double/steamdeck_trigger_r2.png",
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
	
	# Fallback to Xbox if not found (standard practice)
	if controller_type != ControllerManager.ControllerType.XBOX:
		path = XBOX_GLYPHS.get(button, "")
		if path and FileAccess.file_exists(path):
			return load(path)
	
	return null

static func get_controller_axis_glyph(axis_name: String, controller_type = null) -> Texture2D:
	if controller_type == null:
		controller_type = ControllerManager.get_controller_type()
		
	var glyph_set = _get_axis_glyph_set(controller_type)
	var path = glyph_set.get(axis_name, "")
	
	if path and FileAccess.file_exists(path):
		return load(path)
		
	# Fallback to Xbox
	if controller_type != ControllerManager.ControllerType.XBOX:
		path = XBOX_AXIS_GLYPHS.get(axis_name, "")
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

static func _get_axis_glyph_set(controller_type) -> Dictionary:
	match controller_type:
		ControllerManager.ControllerType.PLAYSTATION:
			return PLAYSTATION_AXIS_GLYPHS
		ControllerManager.ControllerType.STEAM_DECK:
			return STEAM_DECK_AXIS_GLYPHS
		_:
			return XBOX_AXIS_GLYPHS
