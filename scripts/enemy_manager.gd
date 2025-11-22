extends Node2D
class_name EnemyManager

@onready var enemy_spawn: Timer = $EnemySpawn
@onready var enemy_move: Timer = $EnemyMove
@onready var player: CharacterBody2D = %Player
@onready var game_manager: Node2D

signal enemy_spawned(enemy: Node2D)
signal slime_killed

var blue_slime_scene = preload("res://scenes/blue_slime.tscn")
var slimes_killed: int = 0

const TILES = 12
const TILE_SIZE = 32

func _ready() -> void:
	game_manager = get_node("/root/MagicGarden/GameManager")
	enemy_spawn.timeout.connect(_on_enemy_spawn_timeout)
	enemy_move.timeout.connect(_on_enemy_move_timeout)

func start_enemy_systems() -> void:
	enemy_spawn.start()
	enemy_move.start()

func stop_enemy_systems() -> void:
	enemy_spawn.stop()
	enemy_move.stop()

func spawn_enemy() -> void:
	var enemy_pos = random_pos()
	var attempts = 0
	
	while not is_valid_spawn_position(enemy_pos) and attempts < 100:
		enemy_pos = random_pos()
		attempts += 1
	
	if attempts >= 100:
		return
	
	var enemy_instance = blue_slime_scene.instantiate()
	enemy_instance.position = enemy_pos
	enemy_instance.position += Vector2.RIGHT * 16
	enemy_instance.position += Vector2.DOWN * 16
	
	game_manager.add_child(enemy_instance)
	
	enemy_instance.was_killed.connect(_on_slime_killed)
	
	enemy_instance.sprite.play("spawn")
	await enemy_instance.sprite.animation_finished
	enemy_instance.sprite.play("idle_down")
	
	enemy_spawned.emit(enemy_instance)

func move_all_enemies() -> void:
	var enemies = get_tree().get_nodes_in_group("mobs")
	for enemy in enemies:
		if enemy.has_method("move"):
			enemy.move()

func random_pos() -> Vector2i:
	randomize()
	var x = (randi_range(0, TILES - 1) * TILE_SIZE)
	var y = (randi_range(0, TILES - 1) * TILE_SIZE)
	return Vector2i(x, y)

func is_valid_spawn_position(pos: Vector2) -> bool:
	if not player or not game_manager:
		return false
		
	if player.position == pos:
		return false
	
	for child in game_manager.get_children():
		if child is AnimatedSprite2D and child.position == pos:
			return false
	
	if game_manager.has_node("TrailManager"):
		var trail_manager = game_manager.get_node("TrailManager")
		for yoyo_instance in trail_manager.trail:
			if is_instance_valid(yoyo_instance) and yoyo_instance.position == pos:
				return false
	
	return true

func get_enemy_count() -> int:
	return get_tree().get_nodes_in_group("mobs").size()

func clear_all_enemies() -> void:
	var enemies = get_tree().get_nodes_in_group("mobs")
	for enemy in enemies:
		enemy.queue_free()

func get_slimes_killed() -> int:
	return slimes_killed

func _on_enemy_spawn_timeout() -> void:
	spawn_enemy()
	enemy_spawn.start()

func _on_enemy_move_timeout() -> void:
	move_all_enemies()
	enemy_move.start()

func _on_slime_killed() -> void:
	slimes_killed += 1
	slime_killed.emit()
