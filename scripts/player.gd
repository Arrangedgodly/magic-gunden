@icon("res://assets/icons/icon_character.png")
extends CharacterBody2D
class_name Player

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var move_timer: Timer = %MoveTimer
@onready var game_manager: Node2D = %GameManager
@onready var ammo_manager: AmmoManager = %AmmoManager
@onready var trail_manager: TrailManager = %TrailManager
@onready var score_manager: ScoreManager = %ScoreManager
@onready var tutorial: Tutorial = %Tutorial
@onready var crosshair: Sprite2D = $Crosshair
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var death_sfx: AudioStream = preload("res://assets/sounds/sfx/Retro Negative Melody 02 - space voice pad.wav")

var score_popup_scene = preload("res://scenes/ui/score_popup.tscn")
var projectile_scene = preload("res://scenes/projectile.tscn")
var laser_beam_scene = preload("res://scenes/effects/laser_beam.tscn")

var last_direction = null
var aim_direction = DOWN
var animation_speed = 5
var powerup_manager: PowerupManager
var move_deadzone: float = 0.5
var aim_deadzone: float = 0.5
var finished_moving: bool = false
var four_way_shot_active: bool = false
var gameplay_area: Node2D
var is_attacking: bool = false
var start_position: Vector2
var movement_tween: Tween
var virtual_move_input: Vector2 = Vector2.ZERO
var virtual_aim_input: Vector2 = Vector2.ZERO
var can_fire: bool = true

const TILE_SIZE = 32
const UP = Vector2(0, -1)
const DOWN = Vector2(0, 1)
const LEFT = Vector2(-1, 0)
const RIGHT = Vector2(1, 0)

func _ready():
	powerup_manager = get_node("/root/MagicGarden/Systems/PowerupManager")
	gameplay_area = get_node("/root/MagicGarden/World/GameplayArea")
	
	tutorial.can_fire.connect(_on_tutorial_can_fire)
	
	move_timer.timeout.connect(_on_move_timer_timeout)
	
	position = position.snapped(Vector2.ONE * TILE_SIZE)
	position += Vector2.ONE * 8
	start_position = position
	
	powerup_active()

func _process(_delta: float) -> void:
	var move_vector = Vector2(
		Input.get_action_strength("move-right") - Input.get_action_strength("move-left"),
		Input.get_action_strength("move-down") - Input.get_action_strength("move-up")) + virtual_move_input
	
	if move_vector.length() > 1.0:
		move_vector = move_vector.normalized()

	handle_movement_input(move_vector)

	var aim_vector_input = Vector2(
		Input.get_action_strength("aim-right") - Input.get_action_strength("aim-left"),
		Input.get_action_strength("aim-down") - Input.get_action_strength("aim-up")) + virtual_aim_input

	handle_aim_input(aim_vector_input)

	if Input.is_action_just_pressed("attack"):
		trigger_attack()

func _on_move_timer_timeout() -> void:
	if is_attacking:
		if can_fire:
			ammo_manager.handle_attack()
		is_attacking = false
	if last_direction != null:
		move(last_direction)

func _on_tutorial_can_fire() -> void:
	can_fire = true

func move(dir):
	var new_position = position + (dir * TILE_SIZE)
	
	if powerup_manager and powerup_manager.is_jump_active:
		new_position = powerup_manager.check_jump_movement(new_position, dir)
	
	if trail_manager.has_trail():
		var first_trail_position = trail_manager.get_first_trail_position()
		if first_trail_position.distance_to(to_local(new_position)) < 5.0:
			return
	
	trail_manager.update_move_history(global_position)
	
	if movement_tween and movement_tween.is_valid():
		movement_tween.kill()
	
	movement_tween = create_tween()
	movement_tween.tween_property(self, "position", new_position, 1.0/animation_speed).set_trans(Tween.TRANS_SINE)
	
	trail_manager.move_trail()

func handle_movement_input(input_vector: Vector2) -> void:
	var new_direction = null
	
	if Input.is_action_just_pressed("move-left") and last_direction != RIGHT:
		new_direction = LEFT
	elif Input.is_action_just_pressed("move-right") and last_direction != LEFT:
		new_direction = RIGHT
	elif Input.is_action_just_pressed("move-up") and last_direction != DOWN:
		new_direction = UP
	elif Input.is_action_just_pressed("move-down") and last_direction != UP:
		new_direction = DOWN
	elif input_vector.length() > move_deadzone:
		var abs_x = abs(input_vector.x)
		var abs_y = abs(input_vector.y)
		
		if abs_x > abs_y:
			if input_vector.x > 0 and last_direction != LEFT:
				new_direction = RIGHT
			elif input_vector.x < 0 and last_direction != RIGHT:
				new_direction = LEFT
		else:
			if input_vector.y > 0 and last_direction != UP:
				new_direction = DOWN
			elif input_vector.y < 0 and last_direction != DOWN:
				new_direction = UP
	
	if new_direction != null and new_direction != last_direction:
		last_direction = new_direction
		animation_tree.set("parameters/Run/BlendSpace2D/blend_position", input_vector)
		animation_tree["parameters/playback"].travel("Run")

func handle_aim_input(aim_vector: Vector2) -> void:
	if powerup_manager.is_auto_aim_active():
		return
	
	if Input.is_action_just_pressed("aim-down"):
		aim_direction = DOWN
	elif Input.is_action_just_pressed("aim-up"):
		aim_direction = UP
	elif Input.is_action_just_pressed("aim-left"):
		aim_direction = LEFT
	elif Input.is_action_just_pressed("aim-right"):
		aim_direction = RIGHT
	elif aim_vector.length() > aim_deadzone:
		var abs_x = abs(aim_vector.x)
		var abs_y = abs(aim_vector.y)
		
		if abs_x > abs_y:
			aim_direction = RIGHT if aim_vector.x > 0 else LEFT
		else:
			aim_direction = DOWN if aim_vector.y > 0 else UP

func die():
	move_timer.stop()
	
	if game_manager.is_tutorial_mode:
		game_manager.handle_tutorial_death()
		return
		
	AudioManager.play_sound(death_sfx)
	game_manager.end_game()
	animation_tree.set("parameters/Death/BlendSpace2D/blend_position", last_direction)
	animation_tree.get("parameters/playback").travel("Death")
	move_timer.stop()
	
	await animation_tree.animation_finished
	
	process_mode = Node.PROCESS_MODE_DISABLED
	crosshair.visible = false
	crosshair.process_mode = Node.PROCESS_MODE_DISABLED

func _on_projectile_shot_missed() -> void:
	score_manager.reset_current_killstreak()

func create_score_popup(value):
	var score_popup = score_popup_scene.instantiate()
	add_child(score_popup)
	score_popup.handle_popup(value)

func attack():
	if not can_fire:
		return
		
	var directions_to_shoot = [aim_direction]
	
	if four_way_shot_active:
		directions_to_shoot = [UP, DOWN, LEFT, RIGHT]
	
	for dir in directions_to_shoot:
		if powerup_manager.is_laser_active():
			var laser = laser_beam_scene.instantiate()
			var spawn_pos = global_position
			gameplay_area.add_child(laser)
			laser.setup(spawn_pos, dir)
		else:
			var projectile = projectile_scene.instantiate()
			projectile.set_direction(dir)
			
			if powerup_manager and powerup_manager.is_pierce_active():
				projectile.is_piercing = true
			
			if powerup_manager and powerup_manager.is_ricochet_active():
				projectile.can_ricochet = true
				projectile.max_bounces = powerup_manager.get_ricochet_max_bounces()
				
			projectile.shot_missed.connect(_on_projectile_shot_missed)
				
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

func reset_to_start() -> void:
	if movement_tween and movement_tween.is_valid():
		movement_tween.kill()
		
	position = start_position
	
	if move_timer.is_stopped():
		move_timer.start()

func trigger_attack() -> void:
	is_attacking = true
