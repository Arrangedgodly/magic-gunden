extends Powerup
class_name FlamesPowerup

var flaming_enemies: Dictionary = {}
var enemy_manager: EnemyManager

func _ready() -> void:
	super._ready()
	type = PowerupType.Flames

func activate(manager: PowerupManager) -> void:
	super.activate(manager)
	
	enemy_manager = manager.enemy_manager
	
	var enemies = get_tree().get_nodes_in_group("mobs")
	for enemy in enemies:
		if is_instance_valid(enemy):
			ignite_enemy(enemy)
	
	if enemy_manager:
		enemy_manager.enemy_spawned.connect(_on_enemy_spawned)
	
	manager.register_flames_powerup(self)
	manager.powerup_activated.emit("Flames")

func get_powerup_name() -> String:
	return "Flames"

func _on_enemy_spawned(enemy: Node2D) -> void:
	if is_active and is_instance_valid(enemy):
		ignite_enemy(enemy)

func ignite_enemy(enemy: Node2D) -> void:
	if flaming_enemies.has(enemy) or not is_active:
		return
	
	if enemy.has_method("show_fire"):
		enemy.show_fire()
	
	var burn_timer = Timer.new()
	burn_timer.wait_time = 3.0
	burn_timer.one_shot = true
	add_child(burn_timer)
	
	flaming_enemies[enemy] = burn_timer
	
	if enemy.has_node("AnimatedSprite2D"):
		var enemy_sprite = enemy.get_node("AnimatedSprite2D")
		var tween = create_tween()
		tween.set_loops(0)
		tween.tween_property(enemy_sprite, "modulate", Color(1.5, 0.5, 0.2), 0.3)
		tween.tween_property(enemy_sprite, "modulate", Color(1, 1, 1), 0.3)
		
		if not enemy.has_meta("flame_tween"):
			enemy.set_meta("flame_tween", tween)
	
	burn_timer.timeout.connect(func(): kill_burning_enemy(enemy))
	burn_timer.start()

func kill_burning_enemy(enemy: Node2D) -> void:
	if not is_instance_valid(enemy):
		if flaming_enemies.has(enemy):
			var flame_timer = flaming_enemies[enemy]
			if is_instance_valid(timer):
				flame_timer.queue_free()
			flaming_enemies.erase(enemy)
		return
	
	if enemy.has_meta("flame_tween"):
		var tween = enemy.get_meta("flame_tween")
		if tween and tween.is_valid():
			tween.kill()
		enemy.remove_meta("flame_tween")
	
	if enemy.has_node("AnimatedSprite2D"):
		var enemy_sprite = enemy.get_node("AnimatedSprite2D")
		enemy_sprite.modulate = Color(1, 1, 1, 1)
	
	if enemy.has_method("kill"):
		enemy.kill()
	
	if flaming_enemies.has(enemy):
		var flame_timer = flaming_enemies[enemy]
		if is_instance_valid(flame_timer):
			flame_timer.queue_free()
		flaming_enemies.erase(enemy)

func clear_flames() -> void:
	for enemy in flaming_enemies.keys():
		if is_instance_valid(enemy):
			if enemy.has_meta("flame_tween"):
				var tween = enemy.get_meta("flame_tween")
				if tween and tween.is_valid():
					tween.kill()
				enemy.remove_meta("flame_tween")
			
			if enemy.has_method("hide_fire"):
				enemy.hide_fire()
			
			if enemy.has_node("AnimatedSprite2D"):
				var enemy_sprite = enemy.get_node("AnimatedSprite2D")
				enemy_sprite.modulate = Color(1, 1, 1, 1)
		
		var flame_timer = flaming_enemies[enemy]
		if is_instance_valid(flame_timer):
			flame_timer.queue_free()
	
	flaming_enemies.clear()

func _on_timeout() -> void:
	if enemy_manager and enemy_manager.enemy_spawned.is_connected(_on_enemy_spawned):
		enemy_manager.enemy_spawned.disconnect(_on_enemy_spawned)
	
	clear_flames()
	super._on_timeout()
