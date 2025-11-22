extends Node2D

var move_timer: Timer
var player: CharacterBody2D
var pause_screen: Node2D
var time_counter: Timer

@export var background_music: AudioStream
@export var pickup_sfx: AudioStream
@export var death_sfx: AudioStream
@export var ammo_error_sfx: AudioStream

var projectile_scene = preload("res://scenes/projectile.tscn")
var score_popup_scene = preload("res://scenes/score_popup.tscn")

const tiles = 12
const tile_size = 32
const cell_size = Vector2i(32, 32)
var animation_speed = 5
var grid_size
var game_started: bool = false
var last_direction = null
var aim_direction = down
const up = Vector2(0, -1)
const down = Vector2(0, 1)
const left = Vector2(-1, 0)
const right = Vector2(1, 0)
var pickup_count : int
var level = 1
var game_paused : bool
var is_attacking : bool
var ammo = Ammo.new()
var game_scene_root: Node2D

signal level_changed(new_level: int)
signal gem_converted(point_value: int)
signal game_ended(final_score: int, kill_count: int, time_alive: int, gems_captured: int)
signal new_highscore(new_score: int)
signal new_high_killcount(new_killcount: int)
signal new_high_time_alive(new_time_alive: int)
signal new_high_gems_captured(new_gems_captured: int)
signal killstreak(new_killstreak: int)
signal current_ammo(new_ammo: int)
signal ui_visible(visible: bool)
signal update_score(new_score: int)
signal increase_ammo
signal decrease_ammo

func initialize_game_scene(scene_root: Node2D, _player: CharacterBody2D, _move_timer: Timer, _pause_screen: Node2D, _time_counter: Timer) -> void:
	game_scene_root = scene_root
	player = _player
	move_timer = _move_timer
	pause_screen = _pause_screen
	time_counter = _time_counter
	
	if TrailManager:
		TrailManager.trail_item_converted_to_ammo.connect(_on_trail_item_converted_to_ammo)
		TrailManager.trail_released.connect(_on_trail_released)
	
	if PickupManager:
		PickupManager.yoyo_collected.connect(_on_yoyo_collected)
	
	if ScoreManager:
		ScoreManager.score_updated.connect(_on_score_updated)
		ScoreManager.killstreak_changed.connect(_on_killstreak_changed)
		
	move_timer.timeout.connect(_on_move_timer_timeout)
	time_counter.timeout.connect(_on_time_counter_timeout)
	pause_screen.visibility_changed.connect(_on_pause_screen_visibility_changed)

func _input(_event: InputEvent) -> void:
	if not player:
		return
		
	if Input.is_action_just_pressed("move-left") and last_direction != right:
		last_direction = left
		if not game_started:
			start_game()
	if Input.is_action_just_pressed("move-right") and last_direction != left:
		last_direction = right
		if not game_started:
			start_game()
	if Input.is_action_just_pressed("move-up") and last_direction != down:
		last_direction = up
		if not game_started:
			start_game()
	if Input.is_action_just_pressed("move-down") and last_direction != up:
		last_direction = down
		if not game_started:
			start_game()
	if Input.is_action_just_pressed("aim-left"):
		aim_direction = left
	if Input.is_action_just_pressed("aim-right"):
		aim_direction = right
	if Input.is_action_just_pressed("aim-down"):
		aim_direction = down
	if Input.is_action_just_pressed("aim-up"):
		aim_direction = up
	if Input.is_action_just_pressed("detach"):
		TrailManager.release_trail()  # CHANGED!
	if Input.is_action_just_pressed("attack"):
		is_attacking = true

func start_game():
	if not is_initialized():
		return
		
	game_started = true
	AudioManager.play_music(background_music)
	move_timer.start()
	CapturePointManager.start_capture_systems()
	time_counter.start()
	EnemyManager.start_enemy_systems()
	
func end_game():
	if not is_initialized():
		return
		
	AudioManager.stop(background_music)
	AudioManager.play_start(death_sfx)
	move_timer.stop()
	CapturePointManager.stop_capture_systems()
	time_counter.stop()
	EnemyManager.stop_enemy_systems()
	game_ended.emit(ScoreManager.get_score(), ScoreManager.get_kill_count(), ScoreManager.get_time_alive(), ScoreManager.get_gems_captured())
	save_game()

func save_game():
	var saved_game:SavedGame = load("user://save.tres") as SavedGame
	if saved_game == null:
		saved_game = SavedGame.new()
		
	var current_score = ScoreManager.get_score()
	var current_kills = EnemyManager.get_slimes_killed()
	var current_time = ScoreManager.get_time_alive()
	var current_gems = ScoreManager.get_gems_captured()
		
	if not saved_game.score == null:
		if current_score > saved_game.score:
			saved_game.score = current_score
			new_highscore.emit(current_score)
	else:
		saved_game.score = current_score
		new_highscore.emit(current_score)
	
	if not saved_game.slimes_killed == null:
		if current_kills > saved_game.slimes_killed:
			saved_game.slimes_killed = current_kills
			new_high_killcount.emit(current_kills)
	else:
		saved_game.slimes_killed = current_kills
		new_high_killcount.emit(current_kills)
		
	if not saved_game.time_alive == null:
		if current_time > saved_game.time_alive:
			saved_game.time_alive = current_time
			new_high_time_alive.emit(current_time)
	else:
		saved_game.time_alive = current_time
		new_high_time_alive.emit(current_time)
		
	if not saved_game.gems_captured == null:
		if current_gems > saved_game.gems_captured:
			saved_game.gems_captured = current_gems
			new_high_gems_captured.emit(current_gems)
	else:
		saved_game.gems_captured = current_gems
		new_high_gems_captured.emit(current_gems)
	
	ResourceSaver.save(saved_game, "user://save.tres")

func is_initialized() -> bool:
	return player != null and move_timer != null

func random_pos():
	randomize()
	var x = (randi_range(0, tiles - 1) * 32)
	var y = (randi_range(0, tiles - 1) * 32)
	return Vector2i(x,y)
	
func handle_pickup_yoyo():
	AudioManager.play_sound(pickup_sfx)
	pickup_count += 1
	TrailManager.create_trail_segment()

func kill_player():
	player.die()

func handle_attack():
	if ammo.ammo_count == 0:
		AudioManager.play_sound(ammo_error_sfx)
		ScoreManager.reset_kill_count()
		
	if ammo.ammo_count >= 1:
		decrease_ammo.emit()
		ammo.decrease_ammo()
		await player.attack()
		
	current_ammo.emit(ammo.ammo_count)
		
func move(dir):
	if not player:
		return
		
	var new_position = player.position + (dir * tile_size)
	
	if TrailManager.has_trail():
		var first_trail_position = TrailManager.get_first_trail_position()
		if first_trail_position.distance_to(player.to_local(new_position)) < 5.0:
			return
	
	TrailManager.update_move_history(player.global_position)
	
	var tween = create_tween()
	tween.tween_property(player, "position", new_position, 1.0/animation_speed).set_trans(Tween.TRANS_SINE)
	TrailManager.move_trail()
	
func _on_move_timer_timeout() -> void:
	if is_attacking:
		handle_attack()
		is_attacking = false
	if last_direction != null:
		move(last_direction)

func increase_kill_count():
	ScoreManager.increase_kill_count()
	player.create_score_popup(10 * ScoreManager.get_kill_count())
#endregion
	
#region Score Methods

func increase_level():
	level += 1
	level_changed.emit(level)

func _on_time_counter_timeout() -> void:
	ScoreManager.increment_time_alive()

func _on_gem_converted(point_value: int) -> void:
	ScoreManager.add_score(point_value)

func _on_score_updated(new_score: int) -> void:
	update_score.emit(new_score)
	
func _on_killstreak_changed(new_streak: int) -> void:
	killstreak.emit(new_streak)
#endregion

#region TrailManager Signal Handlers (NEW!)

func _on_trail_item_converted_to_ammo(streak: int, new_position: Vector2) -> void:
	var score_popup = score_popup_scene.instantiate()
	score_popup.position = new_position
	score_popup.position += Vector2(-6, -25)
	add_child(score_popup)
	score_popup.handle_popup(10 * streak)
	
	ScoreManager.increment_gems_captured()
	increase_ammo.emit()
	ammo.increase_ammo()
	current_ammo.emit(ammo.clip_count)
	gem_converted.emit((10 * streak))

func _on_trail_released(items_captured: int) -> void:
	if items_captured >= 6:
		PickupManager.spawn_pickup()
	
	CapturePointManager.reset_capture_timers()

#endregion

func _on_pause_screen_visibility_changed() -> void:
	if not game_paused:
		AudioManager.pause(background_music)
		game_paused = true
		ui_visible.emit(false)
	else:
		AudioManager.resume(background_music)
		game_paused = false
		ui_visible.emit(true)

func activate_powerup(type):
	PowerupManager.activate_powerup(type)

func _on_yoyo_collected() -> void:
	handle_pickup_yoyo()
