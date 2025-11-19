extends Sprite2D

var aim_direction: Vector2
var animation_speed: int

const crosshair_up = Vector2(0, -32)
const crosshair_down = Vector2(0, 32)
const crosshair_left = Vector2(-32, 0)
const crosshair_right = Vector2(32, 0)

func _ready() -> void:
	aim_direction = crosshair_down
	animation_speed = 5

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("aim-down"):
		if aim_direction != crosshair_down:
			var tween = create_tween()
			tween.tween_property(self, "position", crosshair_down, 1.0/animation_speed)
			aim_direction = crosshair_down
	if Input.is_action_just_pressed("aim-up"):
		if aim_direction != crosshair_up:
			var tween = create_tween()
			tween.tween_property(self, "position", crosshair_up, 1.0/animation_speed)
			aim_direction = crosshair_up
	if Input.is_action_just_pressed("aim-right"):
		if aim_direction != crosshair_right:
			var tween = create_tween()
			tween.tween_property(self, "position", crosshair_right, 1.0/animation_speed)
			aim_direction = crosshair_right
	if Input.is_action_just_pressed("aim-left"):
		if aim_direction != crosshair_left:
			var tween = create_tween()
			tween.tween_property(self, "position", crosshair_left, 1.0/animation_speed)
			aim_direction = crosshair_left
