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
	poison_timer.timeout.connect(func(): poison_active = false)
	auto_aim_timer.timeout.connect(func(): auto_aim_active = false)
	cyclone_timer.timeout.connect(func(): cyclone_active = false)
	flames_timer.timeout.connect(func(): flames_active = false)
	free_ammo_timer.timeout.connect(func(): free_ammo_active = false)
	ice_timer.timeout.connect(func(): ice_active = false)

func _process(delta: float) -> void:
	if not magnet_timer.is_stopped():
		handle_magnet_effect(delta)

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
