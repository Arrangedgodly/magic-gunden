extends Node2D
class_name EnemyManager

@onready var enemy_spawn: Timer = $EnemySpawn
@onready var enemy_move: Timer = $EnemyMove
@onready var player: CharacterBody2D = %Player
@onready var game_manager: Node2D
@onready var score_manager: Node2D
@onready var spawn: Node2D = %Spawn

signal enemy_spawned(enemy: Node2D)
signal slime_killed

var blue_slime_scene = preload("res://scenes/blue_slime.tscn")
var tutorial_mode: bool = false

const TILES = 12
const TILE_SIZE = 32
const IDLE_ANIMATION_DURATION = 0.5

func _ready() -> void:
	DebugLogger.log_info("=== ENEMY MANAGER READY START ===")
	game_manager = get_node("/root/MagicGarden/Systems/GameManager")
	score_manager = get_node("/root/MagicGarden/Systems/ScoreManager")
	enemy_spawn.timeout.connect(_on_enemy_spawn_timeout)
	enemy_move.timeout.connect(_on_enemy_move_timeout)
	DebugLogger.log_info("=== ENEMY MANAGER READY COMPLETE ===")

func enable_tutorial_mode() -> void:
	DebugLogger.log_info("Enabling enemy manager tutorial mode")
	tutorial_mode = true
	stop_enemy_systems()
	clear_all_enemies()
	DebugLogger.log_info("Enemy manager tutorial mode enabled!")

func start_enemy_systems() -> void:
	DebugLogger.log_info("Starting enemy manager systems")
	enemy_spawn.start()
	enemy_move.start()
	DebugLogger.log_info("Enemy manager systems started!")

func stop_enemy_systems() -> void:
	DebugLogger.log_info("Stopping enemy manager systems")
	enemy_spawn.stop()
	enemy_move.stop()
	DebugLogger.log_info("Enemy manager systems stopped!")

func spawn_enemy(override_pos: Vector2 = Vector2.ZERO) -> void:
	DebugLogger.log_info("Spawning enemy...")
	var enemy_pos: Vector2
	
	if override_pos != Vector2.ZERO:
		enemy_pos = override_pos
	else:
		if tutorial_mode:
			DebugLogger.log_info("Utilizing tutorial random position...")
			enemy_pos = spawn.random_pos_tutorial()
		else:
			DebugLogger.log_info("Utilizing regular random position...")
			enemy_pos = spawn.random_pos()
		var attempts = 0
		while not spawn.is_valid_spawn_position(enemy_pos) and attempts < 100:
			if tutorial_mode:
				DebugLogger.log_info("Position conflict. Re-utilizing tutorial random position...")
				enemy_pos = spawn.random_pos_tutorial()
			else:
				DebugLogger.log_info("Position conflict. Re-utilizing regular random position...")
				enemy_pos = spawn.random_pos()
			attempts += 1
		if attempts >= 100:
			DebugLogger.log_info("Position conflict. Failed over 100 times.")
			return
	
	var enemy_instance = blue_slime_scene.instantiate()
	enemy_instance.position = enemy_pos
	if override_pos == Vector2.ZERO:
		enemy_instance.position += Vector2.RIGHT * 16
		enemy_instance.position += Vector2.DOWN * 16
	
	game_manager.add_child(enemy_instance)
	DebugLogger.log_info("Enemy added to game manager")
	
	DebugLogger.log_info("Connecting enemy signals...")
	enemy_instance.was_killed.connect(_on_slime_killed)
	setup_enemy_collision_exceptions(enemy_instance)
	DebugLogger.log_info("Enemy signals connected successfully!")
	
	enemy_instance.sprite.play("spawn")
	await enemy_instance.sprite.animation_finished
	enemy_instance.sprite.play("idle_down")
	
	enemy_spawned.emit(enemy_instance)
	DebugLogger.log_info("Enemy spawned successfully!")

func setup_enemy_collision_exceptions(new_enemy: Node2D) -> void:
	var enemies = get_tree().get_nodes_in_group("mobs")
	
	for enemy in enemies:
		if enemy == new_enemy or not is_instance_valid(enemy):
			continue
		
		if new_enemy.has_node("CharacterBody2D") and enemy.has_node("CharacterBody2D"):
			var new_body = new_enemy.get_node("CharacterBody2D")
			var existing_body = enemy.get_node("CharacterBody2D")
			
			new_body.add_collision_exception_with(existing_body)
			existing_body.add_collision_exception_with(new_body)

func move_all_enemies() -> void:
	DebugLogger.log_info("Moving all enemies...")
	var enemies = get_tree().get_nodes_in_group("mobs")
	
	var intended_positions: Dictionary = {}
	var move_data: Array = []
	
	for enemy in enemies:
		if not is_instance_valid(enemy) or not enemy.has_method("calculate_move"):
			DebugLogger.log_error("Enemy instance not valid / does not have calculate move method")
			continue
		
		var move_info = enemy.calculate_move(intended_positions)
		
		if move_info.can_move:
			intended_positions[move_info.target_position] = enemy
			move_data.append({
				"enemy": enemy,
				"direction": move_info.direction,
				"target_position": move_info.target_position
			})
		else:
			DebugLogger.log_error("Enemy does not have can_move set to true")
	
	for data in move_data:
		if is_instance_valid(data.enemy) and data.enemy.has_method("start_idle_animation"):
			data.enemy.start_idle_animation(data.direction)
		else:
			DebugLogger.log_error("Enemy instance not valid / does not have start idle animation method")
	
	await get_tree().create_timer(IDLE_ANIMATION_DURATION).timeout
	
	for data in move_data:
		if is_instance_valid(data.enemy) and data.enemy.has_method("execute_movement"):
			data.enemy.execute_movement(data.target_position)
		else:
			DebugLogger.log_error("Enemy instance not valid / does not have execute movement method")
	
	DebugLogger.log_info("Enemies moved successfully!")

func get_enemy_count() -> int:
	return get_tree().get_nodes_in_group("mobs").size()

func clear_all_enemies() -> void:
	DebugLogger.log_info("Clearing all enemies...")
	var enemies = get_tree().get_nodes_in_group("mobs")
	for enemy in enemies:
		enemy.queue_free()
	DebugLogger.log_info("Enemies cleared successfully!")

func _on_enemy_spawn_timeout() -> void:
	spawn_enemy()
	enemy_spawn.start()

func _on_enemy_move_timeout() -> void:
	move_all_enemies()
	enemy_move.start()

func _on_slime_killed() -> void:
	score_manager.saved_game.increase_slimes_killed(1)
	slime_killed.emit()
