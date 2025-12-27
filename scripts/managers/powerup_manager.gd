extends Node2D
class_name PowerupManager

@onready var player: CharacterBody2D = %Player
@onready var game_manager: Node2D = %GameManager
@onready var enemy_manager: EnemyManager = %EnemyManager
@onready var trail_manager: TrailManager = %TrailManager
@onready var spawn: Node2D = %Spawn

var stomp_scene: PackedScene
var magnet_scene: PackedScene
var pierce_scene: PackedScene
var ricochet_scene: PackedScene
var poison_scene: PackedScene
var auto_aim_scene: PackedScene
var flames_scene: PackedScene
var free_ammo_scene: PackedScene
var ice_scene: PackedScene
var jump_scene: PackedScene
var time_pause_scene: PackedScene
var grenade_scene: PackedScene
var four_way_shot_scene: PackedScene
var laser_scene: PackedScene

var available_powerups: Array[PackedScene]
var tutorial_mode: bool = false

var active_jump: JumpPowerup = null
var active_stomp: StompPowerup = null
var active_pierce: PiercePowerup = null
var active_ricochet: RicochetPowerup = null
var active_magnet: MagnetPowerup = null
var active_poison: PoisonPowerup = null
var active_auto_aim: AutoAimPowerup = null
var active_flames: FlamesPowerup = null
var active_free_ammo: FreeAmmoPowerup = null
var active_ice: IcePowerup = null
var active_time_pause: TimePausePowerup = null
var active_grenade: GrenadePowerup = null
var active_four_way_shot: FourWayShotPowerup = null
var active_laser: LaserPowerup = null

signal powerup_activated(type: String)
signal powerup_spawned(position: Vector2)

func _ready() -> void:
	DebugLogger.log_info("=== POWERUP MANAGER READY START ===")
	
	stomp_scene = _safe_load("res://scenes/powerups/stomp.tscn")
	magnet_scene = _safe_load("res://scenes/powerups/magnet.tscn")
	pierce_scene = _safe_load("res://scenes/powerups/pierce.tscn")
	ricochet_scene = _safe_load("res://scenes/powerups/ricochet.tscn")
	poison_scene = _safe_load("res://scenes/powerups/poison.tscn")
	auto_aim_scene = _safe_load("res://scenes/powerups/auto_aim.tscn")
	flames_scene = _safe_load("res://scenes/powerups/flames.tscn")
	free_ammo_scene = _safe_load("res://scenes/powerups/free_ammo.tscn")
	ice_scene = _safe_load("res://scenes/powerups/ice.tscn")
	jump_scene = _safe_load("res://scenes/powerups/jump.tscn")
	time_pause_scene = _safe_load("res://scenes/powerups/time_pause.tscn")
	grenade_scene = _safe_load("res://scenes/powerups/grenade.tscn")
	four_way_shot_scene = _safe_load("res://scenes/powerups/four_way_shot.tscn")
	laser_scene = _safe_load("res://scenes/powerups/laser.tscn")
	
	var all_scenes = [
		stomp_scene, magnet_scene, pierce_scene, ricochet_scene,
		poison_scene, auto_aim_scene, flames_scene, free_ammo_scene,
		ice_scene, jump_scene, time_pause_scene, grenade_scene,
		four_way_shot_scene, laser_scene
	]
	
	for scn in all_scenes:
		if scn != null:
			available_powerups.append(scn)

	DebugLogger.log_info("=== POWERUP MANAGER READY COMPLETE ===")

func _safe_load(path: String) -> PackedScene:
	if ResourceLoader.exists(path):
		return load(path) as PackedScene
	else:
		DebugLogger.log_error("CRITICAL: Failed to load powerup at: " + path)
		return null

func _process(delta: float) -> void:
	if active_magnet and active_magnet.is_active:
		active_magnet.process_effect(delta)
	
	if active_poison and active_poison.is_active:
		active_poison.process_effect(delta)
	
	if active_auto_aim and active_auto_aim.is_active:
		active_auto_aim.process_effect(delta)
	
	if active_free_ammo and active_free_ammo.is_active:
		active_free_ammo.process_effect(delta)

func register_jump_powerup(powerup: JumpPowerup) -> void:
	DebugLogger.log_info("Registering jump powerup...")
	active_jump = powerup

func register_stomp_powerup(powerup: StompPowerup) -> void:
	DebugLogger.log_info("Registering stomp powerup...")
	active_stomp = powerup

func register_pierce_powerup(powerup: PiercePowerup) -> void:
	DebugLogger.log_info("Registering pierce powerup...")
	active_pierce = powerup

func register_ricochet_powerup(powerup: RicochetPowerup) -> void:
	DebugLogger.log_info("Registering ricochet powerup...")
	active_ricochet = powerup

func register_magnet_powerup(powerup: MagnetPowerup) -> void:
	DebugLogger.log_info("Registering magnet powerup...")
	active_magnet = powerup

func register_poison_powerup(powerup: PoisonPowerup) -> void:
	DebugLogger.log_info("Registering poison powerup...")
	active_poison = powerup

func register_auto_aim_powerup(powerup: AutoAimPowerup) -> void:
	DebugLogger.log_info("Registering auto aim powerup...")
	active_auto_aim = powerup

func register_flames_powerup(powerup: FlamesPowerup) -> void:
	DebugLogger.log_info("Registering flames powerup...")
	active_flames = powerup

func register_free_ammo_powerup(powerup: FreeAmmoPowerup) -> void:
	DebugLogger.log_info("Registering free ammo powerup...")
	active_free_ammo = powerup

func register_ice_powerup(powerup: IcePowerup) -> void:
	DebugLogger.log_info("Registering ice powerup...")
	active_ice = powerup

func register_time_pause_powerup(powerup: TimePausePowerup) -> void:
	DebugLogger.log_info("Registering time pause powerup...")
	active_time_pause = powerup

func register_grenade_powerup(powerup: GrenadePowerup) -> void:
	DebugLogger.log_info("Registering grenade powerup...")
	active_grenade = powerup

func register_four_way_shot_powerup(powerup: FourWayShotPowerup) -> void:
	DebugLogger.log_info("Registering four way shot powerup...")
	active_four_way_shot = powerup

func register_laser_powerup(powerup: LaserPowerup) -> void:
	DebugLogger.log_info("Registering laser powerup...")
	active_laser = powerup

func is_jump_active() -> bool:
	return active_jump != null and active_jump.is_active

func is_stomp_active() -> bool:
	return active_stomp != null and active_stomp.is_active

func is_pierce_active() -> bool:
	return active_pierce != null and active_pierce.is_active

func is_ricochet_active() -> bool:
	return active_ricochet != null and active_ricochet.is_active

func is_magnet_active() -> bool:
	return active_magnet != null and active_magnet.is_active

func is_poison_active() -> bool:
	return active_poison != null and active_poison.is_active

func is_auto_aim_active() -> bool:
	return active_auto_aim != null and active_auto_aim.is_active

func is_flames_active() -> bool:
	return active_flames != null and active_flames.is_active

func is_free_ammo_active() -> bool:
	return active_free_ammo != null and active_free_ammo.is_active

func is_ice_active() -> bool:
	return active_ice != null and active_ice.is_active

func is_time_pause_active() -> bool:
	return active_time_pause != null and active_time_pause.is_active

func is_grenade_active() -> bool:
	return active_grenade != null and active_grenade.is_active

func is_four_way_shot_active() -> bool:
	return active_four_way_shot != null and active_four_way_shot.is_active

func is_laser_active() -> bool:
	return active_laser != null and active_laser.is_active

func check_jump_movement(target_pos: Vector2, direction: Vector2) -> Vector2:
	if active_jump and active_jump.is_active:
		return active_jump.modify_movement(target_pos, direction)
	return target_pos

func check_jump_enemy_collision(enemy: Node2D) -> bool:
	if active_jump and active_jump.is_active:
		return active_jump.check_enemy_collision(enemy)
	return false

func get_ricochet_max_bounces() -> int:
	if active_ricochet and active_ricochet.is_active:
		return active_ricochet.get_max_bounces()
	return 0

func get_powerup_timer(p_name: String) -> Timer:
	match p_name:
		"Jump":
			return active_jump.get_timer() if active_jump else null
		"Stomp":
			return active_stomp.get_timer() if active_stomp else null
		"Pierce":
			return active_pierce.get_timer() if active_pierce else null
		"Ricochet":
			return active_ricochet.get_timer() if active_ricochet else null
		"Magnet":
			return active_magnet.get_timer() if active_magnet else null
		"Poison":
			return active_poison.get_timer() if active_poison else null
		"AutoAim":
			return active_auto_aim.get_timer() if active_auto_aim else null
		"Flames":
			return active_flames.get_timer() if active_flames else null
		"FreeAmmo":
			return active_free_ammo.get_timer() if active_free_ammo else null
		"Ice":
			return active_ice.get_timer() if active_ice else null
		"TimePause":
			return active_time_pause.get_timer() if active_time_pause else null
		"Grenade":
			return active_grenade.get_timer() if active_grenade else null
		"FourWayShot":
			return active_four_way_shot.get_timer() if active_four_way_shot else null
		"Laser":
			return active_laser.get_timer() if active_laser else null
	return null

func spawn_powerup() -> void:
	DebugLogger.log_info("Spawning powerup...")
	var powerup_pos
	if tutorial_mode:
		DebugLogger.log_info("Utilizing tutorial random position...")
		powerup_pos = spawn.random_pos_tutorial()
	else:
		DebugLogger.log_info("Utilizing regular random position...")
		powerup_pos = spawn.random_pos()
	var attempts = 0
	
	while not spawn.is_valid_spawn_position(powerup_pos) and attempts < 100:
		if tutorial_mode:
			DebugLogger.log_info("Position conflict. Re-utilizing tutorial random position...")
			powerup_pos = spawn.random_pos_tutorial()
		else:
			DebugLogger.log_info("Position conflict. Re-utilizing regular random position...")
			powerup_pos = spawn.random_pos()
		attempts += 1
	
	if attempts >= 100:
		DebugLogger.log_info("Position conflict. Failed over 100 times.")
		return
	
	var random_scene = available_powerups.pick_random()
	var powerup = random_scene.instantiate()
	powerup.position = powerup_pos
	powerup.position += Vector2(16, 16)
	game_manager.add_child(powerup)
	DebugLogger.log_info("Powerup added to game manager")
	powerup_spawned.emit(powerup_pos)
	DebugLogger.log_info("Powerup spawned successfully!")

func force_spawn_powerup(powerup_scene: PackedScene) -> void:
	DebugLogger.log_info("Force spawning powerup...")
	var pos
	if tutorial_mode:
		DebugLogger.log_info("Utilizing tutorial random position...")
		pos = spawn.random_pos_tutorial()
	else:
		DebugLogger.log_info("Utilizing regular random position...")
		pos = spawn.random_pos()
		
	var powerup = powerup_scene.instantiate()
	
	powerup.position = pos
	powerup.position += Vector2(16, 16)
	game_manager.add_child(powerup)
	DebugLogger.log_info("Powerup added to game manager")
	powerup_spawned.emit(pos)
	DebugLogger.log_info("Powerup force spawned successfully!")
