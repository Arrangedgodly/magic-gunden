extends RichTextLabel

const SPRITE_WIDTH = 128
const SPRITE_HEIGHT = 128
const GLYPH_WIDTH = 64
const GLYPH_HEIGHT = 64

var stomp_image = preload("res://assets/items/powerups/stomp.png")

var gem_frames = [
	preload("res://assets/items/gemframe1.png"),
	preload("res://assets/items/gemframe2.png"),
	preload("res://assets/items/gemframe3.png"),
	preload("res://assets/items/gemframe4.png"),
	preload("res://assets/items/gemframe5.png"),
	preload("res://assets/items/gemframe6.png")
]

var enemy_frames = [
	preload("res://assets/enemies/Slime pack/slimeframe1.png"),
	preload("res://assets/enemies/Slime pack/slimeframe2.png"),
	preload("res://assets/enemies/Slime pack/slimeframe3.png"),
	preload("res://assets/enemies/Slime pack/slimeframe4.png")
]

var capture_frames = [
	preload("res://assets/FX/capture_frame1.png"),
	preload("res://assets/FX/capture_frame2.png"),
	preload("res://assets/FX/capture_frame3.png"),
	preload("res://assets/FX/capture_frame4.png"),
	preload("res://assets/FX/capture_frame5.png"),
	preload("res://assets/FX/capture_frame6.png"),
	preload("res://assets/FX/capture_frame7.png"),
	preload("res://assets/FX/capture_frame8.png"),
	preload("res://assets/FX/capture_frame9.png")
]

var gem_animated: AnimatedTexture = AnimatedTexture.new()
var enemy_animated: AnimatedTexture = AnimatedTexture.new()
var capture_animated: AnimatedTexture = AnimatedTexture.new()

var settings_save: SettingsSave

func _ready() -> void:
	_create_animation(gem_frames, gem_animated)
	_create_animation(enemy_frames, enemy_animated)
	_create_animation(capture_frames, capture_animated)

func _ensure_settings_loaded() -> void:
	if not settings_save:
		await get_tree().process_frame
		settings_save = SettingsManager.get_settings()
		if not settings_save:
			push_error("Failed to load settings_save in hint_label")

func _create_animation(frames: Array, animation: AnimatedTexture) -> void:
	animation.frames = frames.size()
	animation.speed_scale = 10.0
	
	for i in range(frames.size()):
		animation.set_frame_texture(i, frames[i])
		animation.set_frame_duration(i, 1.0)

func add_control_glyph(action: String) -> void:
	_ensure_settings_loaded()
	
	if not settings_save:
		append_text("[???]")
		return
	
	var controller_type = ControllerManager.get_controller_type()
	var is_keyboard = controller_type == ControllerManager.ControllerType.KEYBOARD
	
	if is_keyboard:
		_add_keyboard_glyph(action)
	else:
		_add_controller_glyph(action)

func _add_keyboard_glyph(action: String) -> void:
	var keycode = settings_save.get_control_key(action)
	
	if keycode != -1:
		var glyph = ControlDisplayData.get_keyboard_glyph(keycode)
		if glyph:
			add_image(glyph, GLYPH_WIDTH, GLYPH_HEIGHT)
		else:
			append_text("[%s]" % OS.get_keycode_string(keycode))
	else:
		append_text("[Unbound]")

func _add_controller_glyph(action: String) -> void:
	var controller_type = ControllerManager.get_controller_type()
	
	var button_index = settings_save.get_controller_button(action)
	if button_index != -1:
		var glyph = ControlDisplayData.get_controller_button_glyph(button_index, controller_type)
		if glyph:
			add_image(glyph, GLYPH_WIDTH, GLYPH_HEIGHT)
			return
	
	var axis_data = settings_save.get_controller_axis(action)
	if not axis_data.is_empty():
		var axis_name = _get_axis_name_from_data(axis_data)
		if axis_name:
			var glyph = ControlDisplayData.get_controller_axis_glyph(axis_name, controller_type)
			if glyph:
				add_image(glyph, GLYPH_WIDTH, GLYPH_HEIGHT)
				return

	append_text("[Unbound]")

func _get_axis_name_from_data(axis_data: Dictionary) -> String:
	var axis = axis_data.get("axis", -1)
	var value = axis_data.get("value", 0.0)
	
	match axis:
		JOY_AXIS_LEFT_X:
			return "left_stick_right" if value > 0 else "left_stick_left"
		JOY_AXIS_LEFT_Y:
			return "left_stick_down" if value > 0 else "left_stick_up"
		JOY_AXIS_RIGHT_X:
			return "right_stick_right" if value > 0 else "right_stick_left"
		JOY_AXIS_RIGHT_Y:
			return "right_stick_down" if value > 0 else "right_stick_up"
		JOY_AXIS_TRIGGER_LEFT:
			return "trigger_left"
		JOY_AXIS_TRIGGER_RIGHT:
			return "trigger_right"
	
	return ""

func add_movement_glyphs() -> void:
	add_control_glyph("move-up")
	append_text(" ")
	add_control_glyph("move-down")
	append_text(" ")
	add_control_glyph("move-left")
	append_text(" ")
	add_control_glyph("move-right")

func add_aim_glyphs() -> void:
	add_control_glyph("aim-up")
	append_text(" ")
	add_control_glyph("aim-down")
	append_text(" ")
	add_control_glyph("aim-left")
	append_text(" ")
	add_control_glyph("aim-right")

func reset() -> void:
	clear()
	push_paragraph(HORIZONTAL_ALIGNMENT_CENTER)

func welcome() -> void:
	reset()
	append_text("Let's learn how to survive.")
	pop()

func movement() -> void:
	reset()
	append_text("Use ")
	add_movement_glyphs()
	append_text(" to move around the grid.")
	pop()

func gem_pickup() -> void:
	reset()
	append_text("This is a gem.")
	newline()
	add_image(gem_animated, SPRITE_WIDTH, SPRITE_HEIGHT)
	newline()
	append_text("Walk over the gem to pick it up!")
	newline()
	append_text("They will form a trail behind you.")
	pop()

func capture_zones() -> void:
	reset()
	append_text("These colored tiles are Capture Zones!")
	newline()
	add_image(capture_animated, SPRITE_WIDTH, SPRITE_HEIGHT)
	newline()
	append_text("They are essential for ammo.")

func capture_gems() -> void:
	reset()
	append_text("Move so your GEM TRAIL is on top the capture zones, then press ")
	add_control_glyph("detach")
	append_text(". The trail turns into ammo!")

func zone_movement() -> void:
	reset()
	append_text("Zones swap positions when you capture gems, or if unused too long. Watch how they flash before timing out!")

func attempt_capture_practice() -> void:
	reset()
	append_text("If you capture more than one gem at a time, additional gems gain a score multiplier!")
	newline()
	newline()
	append_text("Try to position yourself over the glowing tiles and capture multiple gems at once.")

func explain_enemy_spawn() -> void:
	reset()
	append_text("Notice how the gems you [color=red]missed[/color] turned into enemies!")
	newline()
	newline()
	append_text("You must carefully position yourself to capture all your gems, or face the consequences.")

func enemy_movement() -> void:
	reset()
	append_text("Slimes turn to face their destination before they move. Watch closely!")

func aiming() -> void:
	reset()
	append_text("Use ")
	add_aim_glyphs()
	append_text(" to aim at the slime. The crosshair shows your aim direction.")

func kill_enemy() -> void:
	reset()
	append_text("Press ")
	add_control_glyph("attack")
	append_text(" to shoot at the slime! Kill it before it reaches you!")

func stomp_powerup() -> void:
	reset()
	append_text("This is a Stomp powerup!")
	newline()
	add_image(stomp_image, SPRITE_WIDTH, SPRITE_HEIGHT)
	newline()
	append_text("Walk over it to collect it.")

func test_powerup() -> void:
	reset()
	append_text("Touch the slimes to kill them! Stomp is active for a limited time.")

func final() -> void:
	reset()
	append_text("You now know the basics. Survive as long as you can!")

func prompt_continue() -> void:
	if OS.has_feature("mobile"):
		newline()
		newline()
		append_text("[Tap anywhere to continue]")
	else:
		newline()
		newline()
		append_text("[Press ")
		add_control_glyph("ui_accept")
		append_text(" to continue]")

func enemy_convert_blocked() -> void:
	reset()
	append_text("That's okay, let's try again.")

func shot_missed() -> void:
	reset()
	append_text("You missed the target!")
	newline()
	newline()
	append_text("Don't worry, we refilled your ammo.")
	newline()
	append_text("Take your time and aim carefully.")

func trail_collision() -> void:
	reset()
	append_text("Too close!")
	newline()
	append_text("You hit your own trail.")
	newline()
	newline()
	append_text("Don't cross your own path!")

func off_map() -> void:
	reset()
	append_text("Careful!")
	newline()
	append_text("You went off the path.")
	newline()
	newline()
	append_text("Let's get you back to safety.")

func enemy_collision() -> void:
	reset()
	append_text("Ouch!")
	newline()
	append_text("You ran into a slime.")
	newline()
	newline()
	append_text("Keep your distance!")
