extends Pickup
class_name IcePickup

var slowed_enemy_list: Array = []
var enemy_manager: EnemyManager
var original_move_timer_wait_time: float = 0.0

func _ready() -> void:
	super._ready()
	type = PickupType.Ice

func activate(manager: PowerupManager) -> void:
	super.activate(manager)
	
	enemy_manager = manager.enemy_manager
	
	if manager.is_ice_active() and manager.active_ice != self:
		original_move_timer_wait_time = manager.active_ice.original_move_timer_wait_time
	else:
		if enemy_manager and enemy_manager.has_node("EnemyMove"):
			var enemy_move_timer = enemy_manager.get_node("EnemyMove")
			if enemy_move_timer is Timer:
				original_move_timer_wait_time = enemy_move_timer.wait_time
				enemy_move_timer.wait_time = original_move_timer_wait_time * 2.0
	
	if enemy_manager:
		enemy_manager.enemy_spawned.connect(_on_enemy_spawned)
	
	slow_all_enemies()
	
	manager.register_ice_powerup(self)
	manager.powerup_activated.emit("Ice")

func get_powerup_name() -> String:
	return "Ice"

func _on_enemy_spawned(enemy: Node2D) -> void:
	if is_active and is_instance_valid(enemy):
		freeze_enemy(enemy)

func freeze_enemy(enemy_instance: Node2D) -> void:
	if slowed_enemy_list.has(enemy_instance):
		return

	if enemy_instance.has_method("show_ice"):
		enemy_instance.show_ice()
	
	slowed_enemy_list.append(enemy_instance)
	
	if enemy_instance.get("sprite"):
		enemy_instance.sprite.modulate = Color(0.5, 0.7, 1.0, 1)
	
	enemy_instance.set_meta("is_slowed", true)

func slow_all_enemies() -> void:
	var enemies = get_tree().get_nodes_in_group("mobs")
	for enemy_instance in enemies:
		if is_instance_valid(enemy_instance):
			freeze_enemy(enemy_instance)

func unfreeze_all_enemies() -> void:
	if powerup_manager.active_ice == self:
		if enemy_manager and enemy_manager.has_node("EnemyMove"):
			var enemy_move_timer = enemy_manager.get_node("EnemyMove")
			if enemy_move_timer is Timer:
				enemy_move_timer.wait_time = original_move_timer_wait_time
		
		for enemy_instance in slowed_enemy_list:
			if is_instance_valid(enemy_instance):
				if enemy_instance.has_method("hide_ice"):
					enemy_instance.hide_ice()
				
				if enemy_instance.get("sprite"):
					enemy_instance.sprite.modulate = Color(1, 1, 1, 1)
				
				if enemy_instance.has_meta("is_slowed"):
					enemy_instance.remove_meta("is_slowed")
	
	slowed_enemy_list.clear()

func _on_timeout() -> void:
	if enemy_manager and enemy_manager.enemy_spawned.is_connected(_on_enemy_spawned):
		enemy_manager.enemy_spawned.disconnect(_on_enemy_spawned)
		
	unfreeze_all_enemies()
	super._on_timeout()
