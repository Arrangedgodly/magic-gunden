extends GridContainer
class_name ControlEntry

signal remap_requested(action: String)

@onready var action_label: Label = %ActionLabel
@onready var input_container: HBoxContainer = %InputContainer
@onready var remap_button: Button = %RemapButton

var current_action: String = ""
var icon_background_style: StyleBoxFlat

func _ready() -> void:
	remap_button.pressed.connect(_on_remap_pressed)

	icon_background_style = StyleBoxFlat.new()
	icon_background_style.bg_color = Color(0, 0, 0, 0.8)
	icon_background_style.set_corner_radius_all(6)
	
	icon_background_style.content_margin_left = 4
	icon_background_style.content_margin_right = 4
	icon_background_style.content_margin_top = 4
	icon_background_style.content_margin_bottom = 4

func setup(action: String, display_name: String, is_controller_mode: bool) -> void:
	current_action = action
	action_label.text = display_name
	
	for child in input_container.get_children():
		child.queue_free()
	
	input_container.add_theme_constant_override("separation", 10)

	var inputs_found = 0
	if is_controller_mode:
		inputs_found = _populate_controller_inputs()
	else:
		inputs_found = _populate_keyboard_inputs()

	if inputs_found == 0:
		var label = Label.new()
		label.text = "Unbound"
		label.modulate = Color(0.5, 0.5, 0.5)
		input_container.add_child(label)

func _on_remap_pressed() -> void:
	remap_requested.emit(current_action)

func _populate_keyboard_inputs() -> int:
	var events = InputMap.action_get_events(current_action)
	var count = 0
	for event in events:
		if event is InputEventKey:
			_add_input_icon(event)
			count += 1
	return count

func _populate_controller_inputs() -> int:
	var events = InputMap.action_get_events(current_action)
	var count = 0
	for event in events:
		if event is InputEventJoypadButton or event is InputEventJoypadMotion:
			_add_input_icon(event)
			count += 1
	return count

func _add_input_icon(event: InputEvent) -> void:
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
		var axis_name = _get_axis_name(event)
		if axis_name:
			glyph = ControlDisplayData.get_controller_axis_glyph(axis_name)
		if not glyph:
			text_fallback = "Axis " + str(event.axis)

	if glyph:
		var bg_panel = PanelContainer.new()
		bg_panel.add_theme_stylebox_override("panel", icon_background_style)

		var texture_rect = TextureRect.new()
		texture_rect.texture = glyph
		texture_rect.custom_minimum_size = Vector2(64, 64)
		texture_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
		texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED

		bg_panel.add_child(texture_rect)
		input_container.add_child(bg_panel)
	else:
		var panel = PanelContainer.new()
		var lbl = Label.new()
		lbl.text = text_fallback
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		panel.add_child(lbl)
		input_container.add_child(panel)

func _get_axis_name(event: InputEventJoypadMotion) -> String:
	match event.axis:
		JOY_AXIS_LEFT_X: return "left_stick_right" if event.axis_value > 0 else "left_stick_left"
		JOY_AXIS_LEFT_Y: return "left_stick_down" if event.axis_value > 0 else "left_stick_up"
		JOY_AXIS_RIGHT_X: return "right_stick_right" if event.axis_value > 0 else "right_stick_left"
		JOY_AXIS_RIGHT_Y: return "right_stick_down" if event.axis_value > 0 else "right_stick_up"
		JOY_AXIS_TRIGGER_LEFT: return "trigger_left"
		JOY_AXIS_TRIGGER_RIGHT: return "trigger_right"
	return ""
