extends Pickup
class_name AutoAimPickup

var current_target: Node2D = null
var player: CharacterBody2D
var game_manager: Node2D

func _ready() -> void:
	super._ready()
	type = PickupType.AutoAim

func activate(manager: PowerupManager) -> void:
	super.activate(manager)
	
	player = manager.player
	game_manager = manager.game_manager
	current_target = null
	
	manager.register_auto_aim_powerup(self)
	manager.powerup_activated.emit("AutoAim")

func get_powerup_name() -> String:
	return "AutoAim"

func process_effect(_delta: float) -> void:
	if not is_active or not player:
		return
	
	var nearest_enemy = find_nearest_enemy()
	
	if nearest_enemy != current_target:
		current_target = nearest_enemy
	
	if current_target and is_instance_valid(current_target):
		var direction = (current_target.global_position - player.global_position).normalized()
		var aim_dir = get_cardinal_direction(direction)
		update_aim_direction(aim_dir)

func find_nearest_enemy() -> Node2D:
	var enemies = get_tree().get_nodes_in_group("mobs")
	var nearest: Node2D = null
	var min_dist: float = INF
	
	for enemy in enemies:
		if not is_instance_valid(enemy):
			continue
		var dist = player.global_position.distance_squared_to(enemy.global_position)
		if dist < min_dist:
			min_dist = dist
			nearest = enemy
	
	return nearest

func get_cardinal_direction(direction: Vector2) -> Vector2:
	var abs_x = abs(direction.x)
	var abs_y = abs(direction.y)
	
	if abs_x > abs_y:
		return Vector2(sign(direction.x), 0)
	else:
		return Vector2(0, sign(direction.y))

func update_aim_direction(direction: Vector2) -> void:
	if game_manager:
		game_manager.aim_direction = direction

func _on_timeout() -> void:
	current_target = null
	super._on_timeout()
