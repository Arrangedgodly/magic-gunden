extends Node2D

#region Variables/Consts/Signals

@onready var move_timer: Timer = $"../MoveTimer"
@onready var player: CharacterBody2D = %Player
@onready var pause_screen: Node2D = $"../PauseScreen"
@onready var time_counter: Timer = $TimeCounter
@onready var stomp_timer: Timer = $StompTimer
@onready var magnet_timer: Timer = $MagnetTimer
@onready var pierce_timer: Timer = $PierceTimer
@onready var trail_manager: TrailManager = %TrailManager
@onready var pickup_manager: PickupManager = %PickupManager
@onready var enemy_manager: EnemyManager = %EnemyManager
@onready var capture_point_manager: CapturePointManager = %CapturePointManager

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
var score : int
var last_direction = null
var aim_direction = down
const up = Vector2(0, -1)
const down = Vector2(0, 1)
const left = Vector2(-1, 0)
const right = Vector2(1, 0)
var pickup_count : int
var kill_count : int
var level = 1
var game_paused : bool
var is_attacking : bool
var time_alive: int
var gems_captured: int
var ammo = Ammo.new()
var scores_to_update: Array
var stomp_active: bool = false
var piercing_active: bool = false
var magnet_active: bool = false

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
#endregion

func _ready() -> void:
	trail_manager.trail_item_converted_to_ammo.connect(_on_trail_item_converted_to_ammo)
	trail_manager.trail_released.connect(_on_trail_released)
	
	pickup_manager.yoyo_collected.connect(_on_yoyo_collected)
	
	capture_point_manager.initialize_first_spawn()

func _input(_event: InputEvent) -> void:
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
		trail_manager.release_trail()  # CHANGED!
	if Input.is_action_just_pressed("attack"):
		is_attacking = true

func _process(_delta: float) -> void:
	if not magnet_timer.is_stopped():
		handle_magnet_effect(_delta)
	if len(scores_to_update) != 0:
		var score_to_add: int = 0
		for score_item in scores_to_update:
			score_to_add += score_item
		scores_to_update.clear()
		score = score + score_to_add
		update_score.emit(score)
		
	
	killstreak.emit(kill_count)
		
#region Game Management Methods

func start_game():
	game_started = true
	AudioManager.play_music(background_music)
	move_timer.start()
	capture_point_manager.start_capture_systems()
	time_counter.start()
	enemy_manager.start_enemy_systems()
	
func end_game():
	AudioManager.stop(background_music)
	AudioManager.play_start(death_sfx)
	move_timer.stop()
	capture_point_manager.stop_capture_systems()
	time_counter.stop()
	enemy_manager.stop_enemy_systems()
	game_ended.emit(score, kill_count, time_alive, gems_captured)
	save_game()

func save_game():
	var saved_game:SavedGame = load("user://save.tres") as SavedGame
	if saved_game == null:
		saved_game = SavedGame.new()
		
	if not saved_game.score == null:
		if score > saved_game.score:
			saved_game.score = score
			new_highscore.emit(score)
	else:
		saved_game.score = score
		new_highscore.emit(score)
	
	if not saved_game.slimes_killed == null:
		if enemy_manager.get_slimes_killed() > saved_game.slimes_killed:
			saved_game.slimes_killed = enemy_manager.get_slimes_killed()
			new_high_killcount.emit(enemy_manager.get_slimes_killed())
	else:
		saved_game.slimes_killed = enemy_manager.get_slimes_killed()
		new_high_killcount.emit(enemy_manager.get_slimes_killed())
		
	if not saved_game.time_alive == null:
		if time_alive > saved_game.time_alive:
			saved_game.time_alive = time_alive
			new_high_time_alive.emit(time_alive)
	else:
		saved_game.time_alive = time_alive
		new_high_time_alive.emit(time_alive)
		
	if not saved_game.gems_captured == null:
		if gems_captured > saved_game.gems_captured:
			saved_game.gems_captured = gems_captured
			new_high_gems_captured.emit(gems_captured)
	else:
		saved_game.gems_captured = gems_captured
		new_high_gems_captured.emit(gems_captured)
	
	ResourceSaver.save(saved_game, "user://save.tres")
#endregion

func random_pos():
	randomize()
	var x = (randi_range(0, tiles - 1) * 32)
	var y = (randi_range(0, tiles - 1) * 32)
	return Vector2i(x,y)
	
func handle_pickup_yoyo():
	AudioManager.play_sound(pickup_sfx)
	pickup_count += 1
	trail_manager.create_trail_segment()

#region Player Methods

func kill_player():
	player.die()

func handle_attack():
	if ammo.ammo_count == 0:
		AudioManager.play_sound(ammo_error_sfx)
		kill_count = 0
		
	if ammo.ammo_count >= 1:
		decrease_ammo.emit()
		ammo.decrease_ammo()
		await player.attack()
		
	current_ammo.emit(ammo.ammo_count)
		
func move(dir):
	var new_position = player.position + (dir * tile_size)
	
	if trail_manager.has_trail():
		var first_trail_position = trail_manager.get_first_trail_position()
		if first_trail_position.distance_to(player.to_local(new_position)) < 5.0:
			return
	
	trail_manager.update_move_history(player.global_position)
	
	var tween = create_tween()
	tween.tween_property(player, "position", new_position, 1.0/animation_speed).set_trans(Tween.TRANS_SINE)
	trail_manager.move_trail()
	
func _on_move_timer_timeout() -> void:
	if is_attacking:
		handle_attack()
		is_attacking = false
	if last_direction != null:
		move(last_direction)

func increase_kill_count():
	kill_count += 1
	scores_to_update.append(10 * kill_count)
	player.create_score_popup(10 * kill_count)
#endregion
	
#region Score Methods

func increase_level():
	level += 1
	level_changed.emit(level)

func _on_time_counter_timeout() -> void:
	time_alive += 1
	time_counter.start()

func _on_gem_converted(point_value: int) -> void:
	scores_to_update.append(point_value)
#endregion

#region TrailManager Signal Handlers (NEW!)

func _on_trail_item_converted_to_ammo(streak: int, new_position: Vector2) -> void:
	var score_popup = score_popup_scene.instantiate()
	score_popup.position = new_position
	score_popup.position += Vector2(-6, -25)
	add_child(score_popup)
	score_popup.handle_popup(10 * streak)
	
	gems_captured += 1
	increase_ammo.emit()
	ammo.increase_ammo()
	current_ammo.emit(ammo.clip_count)
	gem_converted.emit((10 * streak))

func _on_trail_released(items_captured: int) -> void:
	if items_captured >= 6:
		pickup_manager.spawn_pickup()
	
	capture_point_manager.reset_capture_timers()

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
	match type:
		Pickup.PickupType.RED_POTION:
			stomp_active = true
			stomp_timer.start()
			await stomp_timer.timeout
			stomp_active = false
			
		Pickup.PickupType.BLUE_POTION:
			piercing_active = true
			pierce_timer.start()
			await pierce_timer.timeout
			piercing_active = false
			
		Pickup.PickupType.GREEN_POTION:
			magnet_active = true
			magnet_timer.start()
			await magnet_timer.timeout
			magnet_active = false

func handle_magnet_effect(delta):
	var magnet_radius = 160.0 
	var pull_speed = 300.0
	
	for child in get_children():
		if "can_pickup" in child and child.can_pickup:
			var dist = child.global_position.distance_to(player.global_position)
			
			if dist < magnet_radius:
				child.global_position = child.global_position.move_toward(player.global_position, pull_speed * delta)

	var pickups = get_tree().get_nodes_in_group("pickups")
	
	for pickup in pickups:
		if is_instance_valid(pickup):
			var dist = pickup.global_position.distance_to(player.global_position)
			
			if dist < magnet_radius:
				pickup.global_position = pickup.global_position.move_toward(player.global_position, pull_speed * delta)

func _on_yoyo_collected() -> void:
	handle_pickup_yoyo()
