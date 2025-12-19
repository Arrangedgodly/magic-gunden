extends Node2D
class_name PowerupManager

@onready var player: CharacterBody2D = %Player
@onready var game_manager: Node2D = %GameManager
@onready var enemy_manager: EnemyManager = %EnemyManager
@onready var trail_manager: TrailManager = %TrailManager
@onready var spawn: Node2D = %Spawn

var stomp_scene = preload("res://scenes/powerups/stomp.tscn")
var magnet_scene = preload("res://scenes/powerups/magnet.tscn")
var pierce_scene = preload("res://scenes/powerups/pierce.tscn")
var ricochet_scene = preload("res://scenes/powerups/ricochet.tscn")
var poison_scene = preload("res://scenes/powerups/poison.tscn")
var auto_aim_scene = preload("res://scenes/powerups/auto_aim.tscn")
var flames_scene = preload("res://scenes/powerups/flames.tscn")
var free_ammo_scene = preload("res://scenes/powerups/free_ammo.tscn")
var ice_scene = preload("res://scenes/powerups/ice.tscn")
var jump_scene = preload("res://scenes/powerups/jump.tscn")
var time_pause_scene = preload("res://scenes/powerups/time_pause.tscn")
var grenade_scene = preload("res://scenes/powerups/grenade.tscn")
var four_way_shot_scene = preload("res://scenes/powerups/four_way_shot.tscn")
var laser_scene = preload("res://scenes/powerups/laser.tscn")

var available_pickups: Array[PackedScene]
var tutorial_mode: bool = false

var active_jump: JumpPickup = null
var active_stomp: StompPickup = null
var active_pierce: PiercePickup = null
var active_ricochet: RicochetPickup = null
var active_magnet: MagnetPickup = null
var active_poison: PoisonPickup = null
var active_auto_aim: AutoAimPickup = null
var active_flames: FlamesPickup = null
var active_free_ammo: FreeAmmoPickup = null
var active_ice: IcePickup = null
var active_time_pause: TimePausePickup = null
var active_grenade: GrenadePickup = null
var active_four_way_shot: FourWayShotPickup = null
var active_laser: LaserPickup = null

signal powerup_activated(type: String)
signal powerup_spawned(position: Vector2)

func _ready() -> void:
	available_pickups = [
	magnet_scene, 
	pierce_scene, 
	ricochet_scene, 
	stomp_scene,
	poison_scene,
	auto_aim_scene,
	flames_scene,
	free_ammo_scene,
	ice_scene,
	jump_scene,
	time_pause_scene,
	grenade_scene,
	four_way_shot_scene,
	laser_scene
]

func _process(delta: float) -> void:
	if active_magnet and active_magnet.is_active:
		active_magnet.process_effect(delta)
	
	if active_poison and active_poison.is_active:
		active_poison.process_effect(delta)
	
	if active_auto_aim and active_auto_aim.is_active:
		active_auto_aim.process_effect(delta)
	
	if active_free_ammo and active_free_ammo.is_active:
		active_free_ammo.process_effect(delta)

func register_jump_powerup(pickup: JumpPickup) -> void:
	active_jump = pickup

func register_stomp_powerup(pickup: StompPickup) -> void:
	active_stomp = pickup

func register_pierce_powerup(pickup: PiercePickup) -> void:
	active_pierce = pickup

func register_ricochet_powerup(pickup: RicochetPickup) -> void:
	active_ricochet = pickup

func register_magnet_powerup(pickup: MagnetPickup) -> void:
	active_magnet = pickup

func register_poison_powerup(pickup: PoisonPickup) -> void:
	active_poison = pickup

func register_auto_aim_powerup(pickup: AutoAimPickup) -> void:
	active_auto_aim = pickup

func register_flames_powerup(pickup: FlamesPickup) -> void:
	active_flames = pickup

func register_free_ammo_powerup(pickup: FreeAmmoPickup) -> void:
	active_free_ammo = pickup

func register_ice_powerup(pickup: IcePickup) -> void:
	active_ice = pickup

func register_time_pause_powerup(pickup: TimePausePickup) -> void:
	active_time_pause = pickup

func register_grenade_powerup(pickup: GrenadePickup) -> void:
	active_grenade = pickup

func register_four_way_shot_powerup(pickup: FourWayShotPickup) -> void:
	active_four_way_shot = pickup

func register_laser_powerup(pickup: LaserPickup) -> void:
	active_laser = pickup

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
	var pickup_pos
	if tutorial_mode:
		pickup_pos = spawn.random_pos_tutorial()
	else:
		pickup_pos = spawn.random_pos()
	var attempts = 0
	
	while not spawn.is_valid_spawn_position(pickup_pos) and attempts < 100:
		if tutorial_mode:
			pickup_pos = spawn.random_pos_tutorial()
		else:
			pickup_pos = spawn.random_pos()
		attempts += 1
	
	if attempts >= 100:
		return
	
	var random_scene = available_pickups.pick_random()
	var pickup = random_scene.instantiate()
	pickup.position = pickup_pos
	pickup.position += Vector2(16, 16)
	game_manager.add_child(pickup)
	powerup_spawned.emit(pickup_pos)

func force_spawn_powerup(pickup_scene: PackedScene) -> void:
	var pos
	if tutorial_mode:
		pos = spawn.random_pos_tutorial()
	else:
		pos = spawn.random_pos()
		
	var pickup = pickup_scene.instantiate()
	
	pickup.position = pos
	pickup.position += Vector2(16, 16)
	game_manager.add_child(pickup)
	powerup_spawned.emit(pos)
