extends Pickup
class_name JumpPickup

const TILE_SIZE = 32

var player: CharacterBody2D
var game_manager: Node2D
var recently_jumped_enemies: Array = []

func _ready() -> void:
	super._ready()
	type = PickupType.Jump

func activate(manager: PowerupManager) -> void:
	super.activate(manager)
	
	player = manager.player
	game_manager = manager.game_manager
	recently_jumped_enemies.clear()
	
	manager.register_jump_powerup(self)
	manager.powerup_activated.emit("Jump")

func get_powerup_name() -> String:
	return "Jump"

func modify_movement(target_pos: Vector2, direction: Vector2) -> Vector2:
	if not is_active:
		return target_pos
	
	var enemy = find_enemy_at_pos(target_pos)
	
	if enemy:
		var jump_pos = target_pos + (direction * TILE_SIZE)
		
		if is_position_in_bounds(jump_pos) and not find_enemy_at_pos(jump_pos):
			
			handle_jump_interaction(enemy)
			
			return jump_pos
			
	return target_pos

func handle_jump_interaction(enemy: Node2D) -> void:
	if not game_manager.has_node("TrailManager"):
		return
		
	var trail_manager = game_manager.get_node("TrailManager")
	
	if trail_manager.has_trail():
		if enemy.has_method("kill"):
			enemy.kill()
			
		var first_gem = trail_manager.trail.pop_front()
		if is_instance_valid(first_gem):
			first_gem.queue_free()
		
		detach_remaining_trail(trail_manager)

func detach_remaining_trail(trail_manager) -> void:
	for gem in trail_manager.trail:
		if is_instance_valid(gem):
			gem.remove_from_group("equipped")
			
			if gem.has_method("enable_pickup"):
				gem.enable_pickup()
			
			snap_gem_to_grid(gem)

	trail_manager.trail.clear()
	trail_manager.move_history.clear()
	trail_manager.pickup_count = 0
	trail_manager.capture_count = 0

func snap_gem_to_grid(gem: Node2D) -> void:
	var grid_x = floor(gem.position.x / TILE_SIZE)
	var grid_y = floor(gem.position.y / TILE_SIZE)
	gem.position = Vector2(grid_x * TILE_SIZE + 16, grid_y * TILE_SIZE + 16)

func find_enemy_at_pos(pos: Vector2) -> Node2D:
	var enemies = get_tree().get_nodes_in_group("mobs")
	for enemy in enemies:
		if is_instance_valid(enemy):
			if enemy.position.distance_to(pos) < 16:
				return enemy
	return null

func check_enemy_collision(_enemy: Node2D) -> bool:
	return is_active

func is_position_in_bounds(pos: Vector2) -> bool:
	var grid_size = 12 * TILE_SIZE
	return pos.x >= 0 and pos.x < grid_size and pos.y >= 0 and pos.y < grid_size

func _on_timeout() -> void:
	recently_jumped_enemies.clear()
	super._on_timeout()
