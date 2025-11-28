extends Pickup
class_name TimePausePickup

var frozen_enemy_list: Array = []
var enemy_manager: EnemyManager
var warning_tween: Tween = null
var WARNING_TIME: float = 2.0

func _ready() -> void:
	super._ready()
	type = PickupType.TimePause

func activate(manager: PowerupManager) -> void:
	super.activate(manager)
	
	enemy_manager = manager.enemy_manager
	freeze_all_enemies()
	
	await get_tree().create_timer(duration - WARNING_TIME).timeout
	if is_active:
		start_warning_flash()
	
	manager.register_time_pause_powerup(self)
	manager.powerup_activated.emit("TimePause")

func get_powerup_name() -> String:
	return "TimePause"

func freeze_all_enemies() -> void:
	frozen_enemy_list.clear()
	
	if enemy_manager and enemy_manager.has_node("EnemyMove"):
		var enemy_move_timer = enemy_manager.get_node("EnemyMove")
		if enemy_move_timer is Timer:
			enemy_move_timer.paused = true
	
	var enemies = get_tree().get_nodes_in_group("mobs")
	for enemy_instance in enemies:
		if is_instance_valid(enemy_instance):
			frozen_enemy_list.append(enemy_instance)
			
			var enemy_sprite = enemy_instance.sprite
			enemy_sprite.modulate = Color(0.5, 0.5, 0.5, 1)
			enemy_sprite.pause()
			
			enemy_instance.set_meta("is_time_frozen", true)

func start_warning_flash() -> void:
	for enemy_instance in frozen_enemy_list:
		if is_instance_valid(enemy_instance):
			var enemy_sprite = enemy_instance.sprite
			
			var flash_tween = create_tween()
			flash_tween.set_loops(0)
			
			flash_tween.tween_property(enemy_sprite, "modulate", Color(1, 1, 1, 1), 0.3)
			flash_tween.tween_property(enemy_sprite, "modulate", Color(0.5, 0.5, 0.5, 1), 0.3)
			
			enemy_instance.set_meta("time_freeze_flash_tween", flash_tween)

func unfreeze_all_enemies() -> void:
	if enemy_manager and enemy_manager.has_node("EnemyMove"):
		var enemy_move_timer = enemy_manager.get_node("EnemyMove")
		if enemy_move_timer is Timer:
			enemy_move_timer.paused = false
	
	for enemy_instance in frozen_enemy_list:
		if is_instance_valid(enemy_instance):
			if enemy_instance.has_meta("time_freeze_flash_tween"):
				var flash_tween = enemy_instance.get_meta("time_freeze_flash_tween")
				if flash_tween and flash_tween.is_valid():
					flash_tween.kill()
				enemy_instance.remove_meta("time_freeze_flash_tween")
			
			var enemy_sprite = enemy_instance.sprite
			enemy_sprite.modulate = Color(1, 1, 1, 1)
			enemy_sprite.play()
			
			if enemy_instance.has_meta("is_time_frozen"):
				enemy_instance.remove_meta("is_time_frozen")
	
	frozen_enemy_list.clear()

func _on_timeout() -> void:
	unfreeze_all_enemies()
	super._on_timeout()
