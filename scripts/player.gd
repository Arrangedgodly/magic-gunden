extends CharacterBody2D
class_name Player

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var move_timer: Timer = $"../MoveTimer"
@onready var game_manager: Node2D = $"../GameManager"
@onready var crosshair: Sprite2D = $Crosshair
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var yoyo_scene = preload("res://scenes/yoyo.tscn")
var score_popup_scene = preload("res://scenes/score_popup.tscn")
var projectile_scene = preload("res://scenes/projectile.tscn")

var last_direction = null
var aim_direction = down
var animation_speed = 5
var powerup_manager: PowerupManager
var move_deadzone: float = 0.5
var aim_deadzone: float = 0.5

const tile_size = 32
const up = Vector2(0, -1)
const down = Vector2(0, 1)
const left = Vector2(-1, 0)
const right = Vector2(1, 0)

func _ready():
	powerup_manager = get_node("/root/MagicGarden/PowerupManager")
	position = position.snapped(Vector2.ONE * tile_size)
	position += Vector2.ONE * 8
	powerup_active()

func _process(_delta: float) -> void:
	var input_vector = Vector2(
		Input.get_action_strength("move-right") - Input.get_action_strength("move-left"),
		Input.get_action_strength("move-down") - Input.get_action_strength("move-up")
	)
	
	handle_movement_input(input_vector)
	handle_aim_input()

func handle_movement_input(input_vector: Vector2) -> void:
	var new_direction = null
	
	if Input.is_action_just_pressed("move-left") and last_direction != right:
		new_direction = left
	elif Input.is_action_just_pressed("move-right") and last_direction != left:
		new_direction = right
	elif Input.is_action_just_pressed("move-up") and last_direction != down:
		new_direction = up
	elif Input.is_action_just_pressed("move-down") and last_direction != up:
		new_direction = down
	elif input_vector.length() > move_deadzone:
		var abs_x = abs(input_vector.x)
		var abs_y = abs(input_vector.y)
		
		if abs_x > abs_y:
			if input_vector.x > 0 and last_direction != left:
				new_direction = right
			elif input_vector.x < 0 and last_direction != right:
				new_direction = left
		else:
			if input_vector.y > 0 and last_direction != up:
				new_direction = down
			elif input_vector.y < 0 and last_direction != down:
				new_direction = up
	
	if new_direction != null and new_direction != last_direction:
		last_direction = new_direction
		animation_tree.set("parameters/Run/BlendSpace2D/blend_position", input_vector)
		animation_tree["parameters/playback"].travel("Run")

func handle_aim_input() -> void:
	var aim_vector = Vector2(
		Input.get_action_strength("aim-right") - Input.get_action_strength("aim-left"),
		Input.get_action_strength("aim-down") - Input.get_action_strength("aim-up")
	)
	
	if Input.is_action_just_pressed("aim-down"):
		aim_direction = down
	elif Input.is_action_just_pressed("aim-up"):
		aim_direction = up
	elif Input.is_action_just_pressed("aim-left"):
		aim_direction = left
	elif Input.is_action_just_pressed("aim-right"):
		aim_direction = right
	elif aim_vector.length() > aim_deadzone:
		var abs_x = abs(aim_vector.x)
		var abs_y = abs(aim_vector.y)
		
		if abs_x > abs_y:
			aim_direction = right if aim_vector.x > 0 else left
		else:
			aim_direction = down if aim_vector.y > 0 else up

func die():
	game_manager.end_game()
	animation_tree.set("parameters/Death/BlendSpace2D/blend_position", last_direction)
	animation_tree.get("parameters/playback").travel("Death")
	set_process(false)
	move_timer.stop()

func create_score_popup(value):
	var score_popup = score_popup_scene.instantiate()
	score_popup.position += Vector2(-6, -25)
	add_child(score_popup)
	score_popup.handle_popup(value)

func attack():
	var projectile = projectile_scene.instantiate()
	projectile.set_direction(aim_direction)
	
	if powerup_manager and powerup_manager.is_pierce_active():
		projectile.is_piercing = true
	
	if powerup_manager and powerup_manager.is_ricochet_active():
		projectile.can_ricochet = true
		projectile.max_bounces = powerup_manager.get_ricochet_max_bounces()
		
	add_child(projectile)

func powerup_active():
	var tween = create_tween()
	tween.tween_property(sprite, "modulate", Color(1, 0, 0), .5).set_trans(Tween.TRANS_SINE)
	tween.tween_property(sprite, "modulate", Color(1, 1, 1), .5).set_trans(Tween.TRANS_SINE)
	tween.tween_property(sprite, "modulate", Color(1, 0, 0), .5).set_trans(Tween.TRANS_SINE)
	tween.tween_property(sprite, "modulate", Color(1, 1, 1), .5).set_trans(Tween.TRANS_SINE)
	tween.tween_property(sprite, "modulate", Color(1, 0, 0), .5).set_trans(Tween.TRANS_SINE)
	tween.tween_property(sprite, "modulate", Color(1, 1, 1), .5).set_trans(Tween.TRANS_SINE)
	tween.tween_property(sprite, "modulate", Color(1, 0, 0), .5).set_trans(Tween.TRANS_SINE)
	tween.tween_property(sprite, "modulate", Color(1, 1, 1), .5).set_trans(Tween.TRANS_SINE)
	tween.tween_property(sprite, "modulate", Color(1, 0, 0), .5).set_trans(Tween.TRANS_SINE)
	tween.tween_property(sprite, "modulate", Color(1, 1, 1), .5).set_trans(Tween.TRANS_SINE)
