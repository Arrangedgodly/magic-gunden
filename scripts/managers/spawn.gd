extends Node2D

const TILES = 12
const TILE_SIZE = 32

@onready var player: CharacterBody2D = %Player
@onready var game_manager: Node2D = %GameManager
@onready var trail_manager: Node2D = %TrailManager

func random_pos() -> Vector2i:
	randomize()
	var x = (randi_range(0, TILES - 1) * TILE_SIZE)
	var y = (randi_range(0, TILES - 1) * TILE_SIZE)
	return Vector2i(x, y)

func random_pos_tutorial() -> Vector2i:
	randomize()
	var min_tile = 2
	var max_tile = TILES - 1 - 2
	
	var x = (randi_range(min_tile, max_tile) * TILE_SIZE)
	var y = (randi_range(min_tile, max_tile) * TILE_SIZE)
	return Vector2i(x, y)

func is_valid_spawn_position(pos: Vector2) -> bool:
	if not player:
		return false
		
	if player.position == pos:
		return false
	
	for child in game_manager.get_children():
		if child is AnimatedSprite2D and child.position == pos:
			return false
	
	for gem_instance in trail_manager.trail:
		if is_instance_valid(gem_instance) and gem_instance.position == pos:
			return false
	
	return true
