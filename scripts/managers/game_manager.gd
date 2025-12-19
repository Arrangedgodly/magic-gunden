extends Node2D
class_name GameManager

@onready var move_timer: Timer = %MoveTimer
@onready var player: CharacterBody2D = %Player
@onready var pause_screen: Node2D = %PauseScreen
@onready var time_counter: Timer = $TimeCounter
@onready var tutorial: Tutorial = %Tutorial

@onready var trail_manager: TrailManager = %TrailManager
@onready var pickup_manager: PickupManager = %PickupManager
@onready var enemy_manager: EnemyManager = %EnemyManager
@onready var capture_point_manager: CapturePointManager = %CapturePointManager
@onready var powerup_manager: PowerupManager = %PowerupManager
@onready var score_manager: ScoreManager = %ScoreManager

@export var background_music: AudioStream
@export var ammo_error_sfx: AudioStream

var projectile_scene = preload("res://scenes/projectile.tscn")
var score_popup_scene = preload("res://scenes/ui/score_popup.tscn")

const TILES = 12
const TILE_SIZE = 32
const UP = Vector2(0, -1)
const DOWN = Vector2(0, 1)
const LEFT = Vector2(-1, 0)
const RIGHT = Vector2(1, 0)

var animation_speed = 5
var grid_size
var game_started: bool = false
var last_direction = null
var current_move_direction = Vector2.ZERO
var aim_direction = DOWN
var level = 1
var game_paused : bool
var is_attacking : bool
var ammo = Ammo.new()
var scores_to_update: Array
var is_tutorial_mode: bool = false
var tutorial_mode_active: bool = false

signal level_changed(new_level: int)
signal gem_converted(point_value: int)
signal game_ended
signal current_ammo(new_ammo: int)
signal ui_visible(visible: bool)
signal update_score(new_score: int)
signal increase_ammo
signal decrease_ammo

func _ready() -> void:
	pause_screen.main_menu_pressed.connect(_on_main_menu_pressed)
	pause_screen.restart_pressed.connect(_on_restart_pressed)
	call_deferred("_initialize")

func _initialize() -> void:
	trail_manager.trail_item_converted_to_ammo.connect(_on_trail_item_converted_to_ammo)
	trail_manager.trail_released.connect(_on_trail_released)
	
	pickup_manager.gem_collected.connect(_on_gem_collected)
	
	if not (tutorial and tutorial.tutorial_save and tutorial.tutorial_save.show_tutorial):
		capture_point_manager.initialize_first_spawn()

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("move-left") and current_move_direction != RIGHT:
		last_direction = LEFT
		if not game_started:
			start_game()
	if Input.is_action_just_pressed("move-right") and current_move_direction != LEFT:
		last_direction = RIGHT
		if not game_started:
			start_game()
	if Input.is_action_just_pressed("move-up") and current_move_direction != DOWN:
		last_direction = UP
		if not game_started:
			start_game()
	if Input.is_action_just_pressed("move-down") and current_move_direction != UP:
		last_direction = DOWN
		if not game_started:
			start_game()
	if Input.is_action_just_pressed("aim-left"):
		aim_direction = LEFT
	if Input.is_action_just_pressed("aim-right"):
		aim_direction = RIGHT
	if Input.is_action_just_pressed("aim-down"):
		aim_direction = DOWN
	if Input.is_action_just_pressed("aim-up"):
		aim_direction = UP
	if Input.is_action_just_pressed("detach"):
		trail_manager.release_trail()
	if Input.is_action_just_pressed("attack"):
		is_attacking = true

func _process(_delta: float) -> void:
	if len(scores_to_update) != 0:
		var score_to_add: int = 0
		for score_item in scores_to_update:
			score_to_add += score_item
		scores_to_update.clear()
		var score = score_manager.saved_game.increase_score(score_to_add)
		update_score.emit(score)

func start_game():
	if game_started:
		return
		
	game_started = true
	
	if not is_tutorial_mode:
		AudioManager.play_music(background_music)
		move_timer.start()
		capture_point_manager.start_capture_systems()
		time_counter.start()
		enemy_manager.start_enemy_systems()
	else:
		move_timer.start()

func start_normal_gameplay_loop():
	is_tutorial_mode = false
	tutorial_mode_active = false
	
	if background_music:
		AudioManager.play_music(background_music)
	
	if capture_point_manager:
		capture_point_manager.disable_tutorial_mode()
		capture_point_manager.start_capture_systems()
	
	time_counter.start()
	enemy_manager.start_enemy_systems()

func end_game():
	AudioManager.stop(background_music)
	move_timer.stop()
	capture_point_manager.stop_capture_systems()
	time_counter.stop()
	enemy_manager.stop_enemy_systems()
	game_ended.emit()
	score_manager.save_game()

func random_pos():
	randomize()
	var x = (randi_range(0, TILES - 1) * 32)
	var y = (randi_range(0, TILES - 1) * 32)
	return Vector2i(x,y)
	
func handle_pickup_gem():
	trail_manager.create_trail_segment()

func kill_player():
	player.die()

func handle_attack():
	if ammo.ammo_count == 0:
		AudioManager.play_sound(ammo_error_sfx)
		score_manager.increase_current_killstreak(1)
		
	if ammo.ammo_count >= 1:
		decrease_ammo.emit()
		ammo.decrease_ammo()
		await player.attack()
		
	current_ammo.emit(ammo.ammo_count)
		
func move(dir):
	var new_position = player.position + (dir * TILE_SIZE)
	
	if powerup_manager and powerup_manager.is_jump_active:
		new_position = powerup_manager.check_jump_movement(new_position, dir)
	
	if trail_manager.has_trail():
		var first_trail_position = trail_manager.get_first_trail_position()
		if first_trail_position.distance_to(player.to_local(new_position)) < 5.0:
			return
	
	trail_manager.update_move_history(player.global_position)
	
	var tween = create_tween()
	tween.tween_property(player, "position", new_position, 1.0/animation_speed).set_trans(Tween.TRANS_SINE)
	
	trail_manager.move_trail()
	
	current_move_direction = dir
	
func _on_move_timer_timeout() -> void:
	if is_attacking:
		handle_attack()
		is_attacking = false
	if last_direction != null:
		move(last_direction)

func increase_kill_count():
	score_manager.saved_game.increase_slimes_killed(1)
	score_manager.increase_current_killstreak(1)
	scores_to_update.append(10 * score_manager.current_killstreak)
	player.create_score_popup(10 * score_manager.current_killstreak)

func increase_level():
	level += 1
	level_changed.emit(level)

func _on_time_counter_timeout() -> void:
	score_manager.saved_game.increase_time_alive(1)
	time_counter.start()

func _on_gem_converted(point_value: int) -> void:
	scores_to_update.append(point_value)

func _on_trail_item_converted_to_ammo(streak: int) -> void:
	var score_popup = score_popup_scene.instantiate()
	player.add_child(score_popup)
	score_popup.handle_popup(10 * streak)
	
	score_manager.saved_game.increase_gems_captured(1)
	increase_ammo.emit()
	ammo.increase_ammo()
	current_ammo.emit(ammo.clip_count)
	gem_converted.emit((10 * streak))

func _on_trail_released(items_captured: int) -> void:
	if items_captured >= 6:
		powerup_manager.spawn_powerup()
	
	if not powerup_manager.is_time_pause_active():
		capture_point_manager.reset_capture_timers()

func _on_pause_screen_visibility_changed() -> void:
	if not game_paused:
		AudioManager.pause(background_music)
		game_paused = true
		ui_visible.emit(false)
		if tutorial:
			if tutorial.visible:
				tutorial.hide()
	else:
		AudioManager.resume(background_music)
		game_paused = false
		ui_visible.emit(true)
		if tutorial and not tutorial.visible:
			tutorial.show()

func _on_gem_collected() -> void:
	handle_pickup_gem()

func _on_main_menu_pressed() -> void:
	AudioManager.stop(background_music)

func _on_restart_pressed() -> void:
	AudioManager.stop(background_music)

func _on_projectile_shot_missed() -> void:
	score_manager.reset_current_killstreak()
