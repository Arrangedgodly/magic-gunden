extends Node2D
class_name PowerupManager

@onready var stomp_timer: Timer = $StompTimer
@onready var magnet_timer: Timer = $MagnetTimer
@onready var pierce_timer: Timer = $PierceTimer
@onready var ricochet_timer: Timer = $RicochetTimer
@onready var poison_timer: Timer = $PoisonTimer
@onready var auto_aim_timer: Timer = $AutoAimTimer
@onready var cyclone_timer: Timer = $CycloneTimer
@onready var flames_timer: Timer = $FlamesTimer
@onready var free_ammo_timer: Timer = $FreeAmmoTimer
@onready var ice_timer: Timer = $IceTimer
@onready var player: CharacterBody2D = %Player
@onready var game_manager: Node2D = %GameManager
@onready var enemy_manager: EnemyManager = %EnemyManager

var stomp_active: bool = false
var piercing_active: bool = false
var magnet_active: bool = false
var ricochet_active: bool = false
var poison_active: bool = false
var auto_aim_active: bool = false
var cyclone_active: bool = false
var flames_active: bool = false
var free_ammo_active: bool = false
var ice_active: bool = false
var timers_map: Dictionary = {}

var poison_trail_scene = preload("res://scenes/poison_trail.tscn")
var last_player_position: Vector2 = Vector2.ZERO
var poison_spawn_distance: float = 32.0

var current_target: Node2D = null

var flaming_enemies: Dictionary = {}

var ammo_generation_interval: float = 1.0
var ammo_generation_timer: float = 0.0

var cyclone_radius: float = 128.0
var cyclone_speed: float = 200.0
var cyclone_angle: float = 0.0
var cyclone_push_force: float = 150.0

var frozen_enemies: Array = []

signal powerup_activated(type: String)

func _ready() -> void:
	timers_map = {
		"Ricochet": ricochet_timer,
		"Magnet": magnet_timer,
		"Pierce": pierce_timer,
		"Stomp": stomp_timer,
		"Poison": poison_timer,
		"AutoAim": auto_aim_timer,
		"Cyclone": cyclone_timer,
		"Flames": flames_timer,
		"FreeAmmo": free_ammo_timer,
		"Ice": ice_timer
	}
	
	ricochet_timer.timeout.connect(func(): ricochet_active = false)
	magnet_timer.timeout.connect(func(): magnet_active = false)
	pierce_timer.timeout.connect(func(): piercing_active = false)
	stomp_timer.timeout.connect(func(): stomp_active = false)
	poison_timer.timeout.connect(func(): 
		poison_active = false
		last_player_position = Vector2.ZERO
	)
	auto_aim_timer.timeout.connect(func(): 
		auto_aim_active = false
		current_target = null
	)
	cyclone_timer.timeout.connect(func(): 
		cyclone_active = false
	)
	flames_timer.timeout.connect(func(): 
		flames_active = false
		clear_flames()
	)
	free_ammo_timer.timeout.connect(func(): 
		free_ammo_active = false
	)
	ice_timer.timeout.connect(func(): 
		ice_active = false
		unfreeze_all_enemies()
	)

func _process(delta: float) -> void:
	if not magnet_timer.is_stopped():
		handle_magnet_effect(delta)
	
	if poison_active and player:
		handle_poison_trail()
	
	if auto_aim_active:
		handle_auto_aim()
	
	if free_ammo_active:
		handle_free_ammo(delta)
	
	if cyclone_active:
		handle_cyclone_effect(delta)

func handle_magnet_effect(delta):
	var magnet_radius = 160.0 
	var pull_speed = 300.0
	
	for child in game_manager.get_children():
		if "can_pickup" in child and child.can_pickup:
			var dist = child.global_position.distance_to(player.global_position)
			
			if dist < magnet_radius:
				child.global_position = child.global_position.move_toward(player.global_position, pull_speed * delta)

	var pickups = get_tree().get_nodes_in_group("pickups")
	
	for pickup in pickups:
		if is_instance_valid(pickup):
			var dist = pickup.global_position.distance_to(player.global_position)
			
			if dist < magnet_radius:
				pickup.global_position = pickup.global_position.move_toward(player.global_position, pull_speed * delta)

func handle_poison_trail() -> void:
	if last_player_position == Vector2.ZERO:
		last_player_position = player.global_position
		return
	
	var distance = player.global_position.distance_to(last_player_position)
	
	if distance >= poison_spawn_distance:
		var poison_instance = poison_trail_scene.instantiate()
		poison_instance.global_position = last_player_position
		game_manager.add_child(poison_instance)
		
		last_player_position = player.global_position

func handle_auto_aim() -> void:
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

func handle_free_ammo(delta: float) -> void:
	ammo_generation_timer += delta
	
	if ammo_generation_timer >= ammo_generation_interval:
		ammo_generation_timer = 0.0
		if game_manager:
			game_manager.increase_ammo.emit()
			game_manager.ammo.increase_ammo()

func handle_cyclone_effect(delta: float) -> void:
	cyclone_angle += cyclone_speed * delta
	if cyclone_angle >= 360:
		cyclone_angle -= 360
	
	var enemies = get_tree().get_nodes_in_group("mobs")
	
	for enemy in enemies:
		if not is_instance_valid(enemy):
			continue
		
		var distance = player.global_position.distance_to(enemy.global_position)
		
		if distance < cyclone_radius:
			var to_enemy = (enemy.global_position - player.global_position).normalized()
			var tangent = Vector2(-to_enemy.y, to_enemy.x)
			
			var push_out = to_enemy * 50.0 * delta
			
			var new_pos = enemy.global_position + (tangent * cyclone_push_force * delta) + push_out
			
			var new_distance = player.global_position.distance_to(new_pos)
			if new_distance > 48.0:
				enemy.global_position = new_pos

func unfreeze_all_enemies() -> void:
	if enemy_manager and enemy_manager.has_node("EnemyMove"):
		var enemy_move_timer = enemy_manager.get_node("EnemyMove")
		if enemy_move_timer is Timer:
			enemy_move_timer.paused = false
	
	for enemy in frozen_enemies:
		if is_instance_valid(enemy) and enemy.has_node("AnimatedSprite2D"):
			enemy.hide_ice()
			var sprite = enemy.get_node("AnimatedSprite2D")
			sprite.modulate = Color(1, 1, 1, 1)
	
	frozen_enemies.clear()

func get_powerup_timer(p_name: String) -> Timer:
	return timers_map.get(p_name)

func activate_ricochet() -> void:
	ricochet_active = true
	ricochet_timer.start()
	powerup_activated.emit("Ricochet")

func activate_magnet() -> void:
	magnet_active = true
	magnet_timer.start()
	powerup_activated.emit("Magnet")

func activate_pierce() -> void:
	piercing_active = true
	pierce_timer.start()
	powerup_activated.emit("Pierce")

func activate_stomp() -> void:
	stomp_active = true
	stomp_timer.start()
	powerup_activated.emit("Stomp")

func activate_poison() -> void:
	poison_active = true
	last_player_position = player.global_position
	poison_timer.start()
	powerup_activated.emit("Poison")

func activate_auto_aim() -> void:
	auto_aim_active = true
	current_target = null
	auto_aim_timer.start()
	powerup_activated.emit("AutoAim")

func activate_flames() -> void:
	flames_active = true
	flames_timer.start()
	
	var enemies = get_tree().get_nodes_in_group("mobs")
	for enemy in enemies:
		if is_instance_valid(enemy):
			ignite_enemy(enemy)
			enemy.show_fire()
	
	powerup_activated.emit("Flames")

func ignite_enemy(enemy: Node2D) -> void:
	if flaming_enemies.has(enemy) or not flames_active:
		return
	
	var burn_timer = Timer.new()
	burn_timer.wait_time = 3.0
	burn_timer.one_shot = true
	add_child(burn_timer)
	
	flaming_enemies[enemy] = burn_timer
	
	if enemy.has_node("AnimatedSprite2D"):
		var sprite = enemy.get_node("AnimatedSprite2D")
		var tween = create_tween()
		tween.set_loops(0)  # Infinite loop
		tween.tween_property(sprite, "modulate", Color(1.5, 0.5, 0.2), 0.3)
		tween.tween_property(sprite, "modulate", Color(1, 1, 1), 0.3)
		
		if not enemy.has_meta("flame_tween"):
			enemy.set_meta("flame_tween", tween)
	
	burn_timer.timeout.connect(func(): kill_burning_enemy(enemy))
	burn_timer.start()

func kill_burning_enemy(enemy: Node2D) -> void:
	if is_instance_valid(enemy):
		if enemy.has_meta("flame_tween"):
			var tween = enemy.get_meta("flame_tween")
			if tween and tween.is_valid():
				tween.kill()
			enemy.remove_meta("flame_tween")
		
		if enemy.has_node("AnimatedSprite2D"):
			var sprite = enemy.get_node("AnimatedSprite2D")
			sprite.modulate = Color(1, 1, 1, 1)
		
		if enemy.has_method("kill"):
			enemy.kill()
	
	if flaming_enemies.has(enemy):
		var timer = flaming_enemies[enemy]
		if is_instance_valid(timer):
			timer.queue_free()
		flaming_enemies.erase(enemy)

func clear_flames() -> void:
	for enemy in flaming_enemies.keys():
		if is_instance_valid(enemy):
			if enemy.has_meta("flame_tween"):
				var tween = enemy.get_meta("flame_tween")
				if tween and tween.is_valid():
					tween.kill()
				enemy.remove_meta("flame_tween")
				enemy.hide_fire()
			
			if enemy.has_node("AnimatedSprite2D"):
				var sprite = enemy.get_node("AnimatedSprite2D")
				sprite.modulate = Color(1, 1, 1, 1)
				enemy.hide_fire()
		
		var timer = flaming_enemies[enemy]
		if is_instance_valid(timer):
			timer.queue_free()
	
	flaming_enemies.clear()

func activate_free_ammo() -> void:
	free_ammo_active = true
	ammo_generation_timer = 0.0
	free_ammo_timer.start()
	powerup_activated.emit("FreeAmmo")

func activate_ice() -> void:
	ice_active = true
	freeze_all_enemies()
	ice_timer.start()
	powerup_activated.emit("Ice")

func freeze_all_enemies() -> void:
	frozen_enemies.clear()
	
	if enemy_manager and enemy_manager.has_node("EnemyMove"):
		var enemy_move_timer = enemy_manager.get_node("EnemyMove")
		if enemy_move_timer is Timer:
			enemy_move_timer.paused = true
	
	var enemies = get_tree().get_nodes_in_group("mobs")
	
	for enemy in enemies:
		if is_instance_valid(enemy):
			enemy.show_ice()
			frozen_enemies.append(enemy)
			
			if enemy.has_node("AnimatedSprite2D"):
				var sprite = enemy.get_node("AnimatedSprite2D")
				sprite.modulate = Color(0.5, 0.7, 1.0, 1)

func activate_cyclone() -> void:
	cyclone_active = true
	cyclone_angle = 0.0
	cyclone_timer.start()
	powerup_activated.emit("Cyclone")
