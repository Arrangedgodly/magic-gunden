extends Node2D

#region Variables/Consts/Signals

@onready var move_timer: Timer = $"../MoveTimer"
@onready var player: CharacterBody2D = %Player
@onready var enemy_spawn: Timer = $EnemySpawn
@onready var enemy_move: Timer = $EnemyMove
@onready var capture_point_timer: Timer = $CapturePointTimer
@onready var pause_screen: Node2D = $"../PauseScreen"
@onready var capture_point_animation: Timer = $CapturePointAnimation
@onready var time_counter: Timer = $TimeCounter
@onready var stomp_timer: Timer = $StompTimer
@onready var magnet_timer: Timer = $MagnetTimer
@onready var pierce_timer: Timer = $PierceTimer

@export var background_music: AudioStream
@export var pickup_sfx: AudioStream
@export var death_sfx: AudioStream
@export var capture_sfx: AudioStream
@export var ammo_error_sfx: AudioStream

var yoyo_scene = preload("res://scenes/yoyo.tscn")
var blue_slime_scene = preload("res://scenes/blue_slime.tscn")
var capture_point_scene = preload("res://scenes/capture_point.tscn")
var projectile_scene = preload("res://scenes/projectile.tscn")
var score_popup_scene = preload("res://scenes/score_popup.tscn")
var pickup_scene = preload("res://scenes/pickup.tscn")

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
var regen_yoyo = true
var yoyo_pos : Vector2i
var move_history : Array
var pickup_count : int
var trail : Array
var capture_count : int
var kill_count : int
var level = 1
var capture_pattern_bar : bool = false
var bars_vertical : bool = true
var game_paused : bool
var is_attacking : bool
var slimes_killed : int
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
	var spawn_point = find_capture_spawn_point()
	spawn_capture_points(spawn_point)
	place_yoyo()

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
		release_trail()
	if Input.is_action_just_pressed("attack"):
		is_attacking = true

func _process(_delta: float) -> void:
	if regen_yoyo:
		place_yoyo()
	
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
	capture_point_timer.start()
	capture_point_animation.start()
	enemy_move.start()
	enemy_spawn.start()
	time_counter.start()
	
func end_game():
	AudioManager.stop(background_music)
	AudioManager.play_start(death_sfx)
	move_timer.stop()
	capture_point_timer.stop()
	capture_point_animation.stop()
	enemy_move.stop()
	enemy_spawn.stop()
	time_counter.stop()
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
		if slimes_killed > saved_game.slimes_killed:
			saved_game.slimes_killed = slimes_killed
			new_high_killcount.emit(slimes_killed)
	else:
		saved_game.slimes_killed = slimes_killed
		new_high_killcount.emit(slimes_killed)
		
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

#region Utility Methods

func random_pos():
	randomize()
	var x = (randi_range(0, tiles - 1) * 32)
	var y = (randi_range(0, tiles - 1) * 32)
	return Vector2i(x,y)

func is_valid_spawn_position(pos: Vector2) -> bool:
	if player.position == pos:
		return false
		
	for child in get_children():
		if child is AnimatedSprite2D and child.position == pos:
			return false
	
	for yoyo_instance in trail:
		if yoyo_instance.position == pos:
			return false
	
	return true
#endregion
	
#region Pickup Methods

func place_yoyo():
	if regen_yoyo:
		regen_yoyo = false
		yoyo_pos = random_pos()
		var attempts = 0
		
		while not is_valid_spawn_position(yoyo_pos) and attempts < 100:
			yoyo_pos = random_pos()
			attempts += 1
		
		if attempts >= 100:
			regen_yoyo = true
			return
			
		var yoyo_instance = yoyo_scene.instantiate()
		yoyo_instance.enable_pickup()
		yoyo_instance.position = yoyo_pos
		yoyo_instance.position += Vector2.RIGHT * 16
		yoyo_instance.position += Vector2.DOWN * 16
		if level == 1:
			yoyo_instance.play('blue')
		elif level == 2:
			yoyo_instance.play('green')
		elif level == 3:
			yoyo_instance.play('red')
		add_child(yoyo_instance)

func spawn_pickup():
	var pickup_pos = random_pos()
	var attempts = 0
	
	while not is_valid_spawn_position(pickup_pos) and attempts < 100:
		pickup_pos = random_pos()
		attempts += 1
	
	if attempts >= 100:
		return
	
	var pickup = pickup_scene.instantiate()
	pickup.position = pickup_pos
	pickup.position += Vector2(16, 16)
	add_child(pickup)
	
func reset_regen_yoyo():
	regen_yoyo = true
	handle_pickup_yoyo()

func handle_pickup_yoyo():
	AudioManager.play_sound(pickup_sfx)
	pickup_count += 1
	create_trail()
	
func create_trail():
	var yoyo_instance = yoyo_scene.instantiate()
	set_deferred("add_child", yoyo_instance)
	var last_position = move_history[len(move_history) - 1]
	var local_position = to_local(last_position)
	yoyo_instance.position = local_position
	yoyo_instance.negate_pickup()
	if level == 1:
		yoyo_instance.play("blue")
	elif level == 2:
		yoyo_instance.play('green')
	elif level == 3:
		yoyo_instance.play('red')
	call_deferred("add_child", yoyo_instance)
	yoyo_instance.add_to_group("equipped")
	trail.append(yoyo_instance)
		
func move_trail():
	if trail.is_empty():
		return
		
	for i in range(len(trail)):
		if i + 1 < len(move_history):
			var target_position = move_history[-(i + 1)]
			var local_position = to_local(target_position)
			var tween = create_tween()
			tween.tween_property(trail[i], "position", local_position, 1.0/animation_speed).set_trans(Tween.TRANS_SINE)

func release_trail():
	for item in trail:
		if is_on_capture_point(item):
			capture_count += 1
			convert_to_ammo(item, capture_count)
		else:
			convert_to_enemy(item)
	
	if capture_count >= 6:
		spawn_pickup()
	
	trail = []		
	capture_count = 0
	capture_point_timer.stop()
	capture_point_timer.emit_signal("timeout")
	capture_point_animation.stop()
	
func is_on_capture_point(item) -> bool:
	var capture_points = get_tree().get_nodes_in_group("capture")
	
	for point in capture_points:
		var detected_body = point.check_detected_body()
		if detected_body:
			if detected_body.position == item.position:
				return true
	
	return false
	
func convert_to_enemy(pickup: Node2D):
	await pickup.flash(Color(255, 0, 0, 255))
	var enemy_instance = blue_slime_scene.instantiate()
	enemy_instance.position = pickup.position
	add_child(enemy_instance)
	enemy_instance.was_killed.connect(increase_slimes_killed)
	pickup.queue_free()
	
func convert_to_ammo(pickup: Node2D, streak: int):
	await pickup.flash(Color(0, 255, 0, 255))
	var score_popup = score_popup_scene.instantiate()
	score_popup.position = pickup.position
	score_popup.position += Vector2(-6, -25)
	add_child(score_popup)
	score_popup.handle_popup(10 * streak)
	gems_captured += 1
	increase_ammo.emit()
	ammo.increase_ammo()
	current_ammo.emit(ammo.clip_count)
	pickup.queue_free()
	gem_converted.emit((10 * streak))
#endregion

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
	
func update_move_history():
	var current_position = player.global_position
	if len(move_history) > pickup_count:
		move_history.pop_front()
	move_history.append(current_position)
		
func move(dir):
	var new_position = player.position + (dir * tile_size)
	
	if trail.size() > 0:
		var first_trail_segment = trail[0]
	
		if first_trail_segment.position.distance_to(player.to_local(new_position)) < 5.0:
			return
			
	await update_move_history()
	
	var tween = create_tween()
	tween.tween_property(player, "position", new_position, 1.0/animation_speed).set_trans(Tween.TRANS_SINE)
	move_trail()
	
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

func increase_slimes_killed():
	slimes_killed += 1
#endregion
				
#region Enemy Methods

func _on_enemy_spawn_timeout() -> void:
	var enemy_pos = random_pos()
	while not is_valid_spawn_position(enemy_pos):
		enemy_pos = random_pos()
	var enemy_instance = blue_slime_scene.instantiate()
	enemy_instance.position = enemy_pos
	enemy_instance.position += Vector2.RIGHT * 16
	enemy_instance.position += Vector2.DOWN * 16
	add_child(enemy_instance)
	enemy_instance.was_killed.connect(increase_slimes_killed)
	enemy_instance.sprite.play("spawn")
	await enemy_instance.sprite.animation_finished
	enemy_instance.sprite.play("idle_down")
	enemy_spawn.start()

func _on_enemy_move_timeout() -> void:
	var enemies = get_tree().get_nodes_in_group("mobs")
	for enemy in enemies:
		enemy.move()
		
	enemy_move.start()
#endregion
	
#region Capture Point Methods

func spawn_capture_points(starting_pos):
	if capture_pattern_bar:
		capture_pattern_bar = false
		for i in range(12):
			var capture_point_instance = capture_point_scene.instantiate()
			capture_point_instance.position = starting_pos
			capture_point_instance.position += Vector2.DOWN * 16
			capture_point_instance.position += Vector2.RIGHT * 16
			if not bars_vertical:
				capture_point_instance.position.x += i * tile_size
			else:
				capture_point_instance.position.y += i * tile_size
			
			if level == 1:
				capture_point_instance.play("blue")
			elif level == 2:
				capture_point_instance.play("green")
			elif level == 3:
				capture_point_instance.play("red")
			add_child(capture_point_instance)
	else:
		capture_pattern_bar = true
		for i in range(16):
			var capture_point_instance = capture_point_scene.instantiate()
			capture_point_instance.position = starting_pos
			capture_point_instance.position += Vector2.DOWN * 16
			capture_point_instance.position += Vector2.RIGHT * 16
			
			@warning_ignore("integer_division")
			var row = i / 4
			var col = i % 4
			
			capture_point_instance.position.x += col * tile_size
			capture_point_instance.position.y += row * tile_size
			
			if row == 0 and (col == 1 or col == 2):
				add_child(capture_point_instance)
			elif row == 1 or row == 2:
				add_child(capture_point_instance)
			elif row == 3 and (col == 1 or col == 2):
				add_child(capture_point_instance)
			
			if level == 1:
				capture_point_instance.play("blue")
	
	capture_point_timer.start()
	capture_point_animation.start()

func find_capture_spawn_point():
	var x = 0
	var y = 0
	randomize()
	if capture_pattern_bar:
		if bars_vertical:
			y = (randi_range(0, tiles - 1) * 32)
			bars_vertical = false
		else:
			x = (randi_range(0, tiles - 1) * 32)
			bars_vertical = true
	else:
		y = (randi_range(1, tiles - 5) * 32)
		x = (randi_range(1, tiles - 5) * 32)
	
	return Vector2i(x,y)
	
func clear_capture_points():
	var capture_points = get_tree().get_nodes_in_group("capture")
	for point in capture_points:
		point.queue_free()

func _on_capture_point_animation_timeout() -> void:
	var capture_points = get_tree().get_nodes_in_group("capture")
	AudioManager.play_sound(capture_sfx)
	for point in capture_points:
		point.flash()
	await get_tree().create_timer(1.5).timeout
	AudioManager.play_sound(capture_sfx)

func _on_capture_point_timer_timeout() -> void:
	await clear_capture_points()
	var spawn_point = find_capture_spawn_point()
	spawn_capture_points(spawn_point)
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
