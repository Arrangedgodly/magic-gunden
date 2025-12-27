extends TouchScreenButton

@export var action_left: String = "move-left"
@export var action_right: String = "move-right"
@export var action_up: String = "move-up"
@export var action_down: String = "move-down"

@onready var knob: Sprite2D = %Knob
@onready var max_distance = shape.radius

var stick_center: Vector2
var touch_index: int = -1

func _ready() -> void:
	stick_center = texture_normal.get_size() / 2

	knob.position = stick_center
	knob.offset = Vector2.ZERO

	var controller_type = ControllerManager.get_controller_type_name()
	if controller_type != "Touch":
		hide()

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			if touch_index == -1:

				var center_global = to_global(stick_center)

				var radius_global = max_distance * global_scale.x

				if event.position.distance_to(center_global) <= radius_global:
					touch_index = event.index
					_update_joystick(event.position)
		else:
			# END TOUCH
			if event.index == touch_index:
				_reset_joystick()

	elif event is InputEventScreenDrag:
		# MOVE TOUCH
		if event.index == touch_index:
			_update_joystick(event.position)

func _update_joystick(global_touch_pos: Vector2) -> void:
	var local_pos = to_local(global_touch_pos)

	var diff = local_pos - stick_center

	knob.position = stick_center + diff.limit_length(max_distance)
	
	_update_input_actions()

func _reset_joystick() -> void:
	touch_index = -1
	knob.position = stick_center

	Input.action_release(action_left)
	Input.action_release(action_right)
	Input.action_release(action_up)
	Input.action_release(action_down)

func _update_input_actions() -> void:
	var vector = knob.position - stick_center
	var dir = vector.normalized()
	var strength = vector.length() / max_distance

	if dir.x > 0:
		Input.action_press(action_right, dir.x * strength)
		Input.action_release(action_left)
	elif dir.x < 0:
		Input.action_press(action_left, -dir.x * strength)
		Input.action_release(action_right)
	else:
		Input.action_release(action_left)
		Input.action_release(action_right)

	if dir.y > 0:
		Input.action_press(action_down, dir.y * strength)
		Input.action_release(action_up)
	elif dir.y < 0:
		Input.action_press(action_up, -dir.y * strength)
		Input.action_release(action_down)
	else:
		Input.action_release(action_up)
		Input.action_release(action_down)
