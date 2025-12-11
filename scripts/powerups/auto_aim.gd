extends Pickup
class_name AutoAimPickup

var current_target: Node2D = null
var player: CharacterBody2D
var game_manager: Node2D
var crosshair: Sprite2D

func _ready() -> void:
	super._ready()
	type = PickupType.AutoAim

func activate(manager: PowerupManager) -> void:
	super.activate(manager)
	
	player = get_node_or_null("/root/MagicGarden/World/GameplayArea/Player")
	if player:
		crosshair = player.get_node("Crosshair")
		
	game_manager = get_node_or_null("/root/MagicGarden/Systems/GameManager")
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
		update_aim_direction(direction)
		update_crosshair_position(direction)

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

func update_aim_direction(direction: Vector2) -> void:
	player.aim_direction = direction

func update_crosshair_position(direction: Vector2) -> void:
	if not crosshair:
		return
	
	# Position the crosshair at 32 pixels distance in the aim direction
	var crosshair_distance = 32.0
	var target_pos = direction * crosshair_distance
	
	# Smoothly tween to the new position
	var tween = create_tween()
	tween.tween_property(crosshair, "position", target_pos, 0.1).set_trans(Tween.TRANS_SINE)

func _on_timeout() -> void:
	current_target = null
	
	if crosshair:
		var tween = create_tween()
		tween.tween_property(crosshair, "position", Vector2(0, 32), 0.2).set_trans(Tween.TRANS_SINE)
		
	super._on_timeout()
