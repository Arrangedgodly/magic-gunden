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
	
	var enemies = get_tree().get_nodes_in_group("mobs")
	for enemy in enemies:
		if not is_instance_valid(enemy):
			continue
		
		var distance = target_pos.distance_to(enemy.position)
		if distance < 16:
			var jump_position = target_pos + (direction * TILE_SIZE)
			
			if is_position_in_bounds(jump_position):
				var jump_blocked = false
				for other_enemy in enemies:
					if other_enemy == enemy or not is_instance_valid(other_enemy):
						continue
					var jump_distance = jump_position.distance_to(other_enemy.position)
					if jump_distance < 16:
						jump_blocked = true
						break
				
				if not jump_blocked:
					if not recently_jumped_enemies.has(enemy):
						recently_jumped_enemies.append(enemy)
						get_tree().create_timer(0.3).timeout.connect(func(): 
							recently_jumped_enemies.erase(enemy)
						)
					return jump_position
	
	return target_pos

func check_enemy_collision(enemy: Node2D) -> bool:
	if not is_active:
		return false
	
	if recently_jumped_enemies.has(enemy):
		return true
	
	return false

func is_position_in_bounds(pos: Vector2) -> bool:
	var grid_size = 12 * TILE_SIZE
	return pos.x >= 0 and pos.x < grid_size and pos.y >= 0 and pos.y < grid_size

func _on_timeout() -> void:
	recently_jumped_enemies.clear()
	super._on_timeout()
