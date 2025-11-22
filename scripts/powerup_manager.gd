extends Node2D

signal powerup_activated(type: Pickup.PickupType)
signal powerup_deactivated(type: Pickup.PickupType)

var stomp_timer: Timer
var magnet_timer: Timer
var pierce_timer: Timer
var player: CharacterBody2D

var stomp_active: bool = false
var piercing_active: bool = false
var magnet_active: bool = false	

func initialize(_player: CharacterBody2D, _stomp_timer: Timer, _magnet_timer: Timer, _pierce_timer: Timer) -> void:
	player = _player
	stomp_timer = _stomp_timer
	magnet_timer = _magnet_timer
	pierce_timer = _pierce_timer

func _process(delta: float) -> void:
	if magnet_active and player:
		handle_magnet_effect(delta)

func activate_powerup(type: Pickup.PickupType) -> void:
	match type:
		Pickup.PickupType.RED_POTION:
			stomp_active = true
			stomp_timer.start()
			powerup_activated.emit(type)
			await stomp_timer.timeout
			stomp_active = false
			powerup_deactivated.emit(type)
			
		Pickup.PickupType.BLUE_POTION:
			piercing_active = true
			pierce_timer.start()
			powerup_activated.emit(type)
			await pierce_timer.timeout
			piercing_active = false
			powerup_deactivated.emit(type)
			
		Pickup.PickupType.GREEN_POTION:
			magnet_active = true
			magnet_timer.start()
			powerup_activated.emit(type)
			await magnet_timer.timeout
			magnet_active = false
			powerup_deactivated.emit(type)

func handle_magnet_effect(delta: float) -> void:
	if not player:
		return
		
	var magnet_radius = 160.0 
	var pull_speed = 300.0
	
	for child in GameManager.get_children():
		if "can_pickup" in child and child.can_pickup:
			var dist = child.global_position.distance_to(player.global_position)
			
			if dist < magnet_radius:
				child.global_position = child.global_position.move_toward(player.global_position, pull_speed * delta)

	var pickups = GameManager.get_tree().get_nodes_in_group("pickups")
	
	for pickup in pickups:
		if is_instance_valid(pickup):
			var dist = pickup.global_position.distance_to(player.global_position)
			
			if dist < magnet_radius:
				pickup.global_position = pickup.global_position.move_toward(player.global_position, pull_speed * delta)

func is_stomp_active() -> bool:
	return stomp_active

func is_piercing_active() -> bool:
	return piercing_active

func is_magnet_active() -> bool:
	return magnet_active

func reset_all() -> void:
	stomp_active = false
	piercing_active = false
	magnet_active = false
	if stomp_timer:
		stomp_timer.stop()
	if magnet_timer:
		magnet_timer.stop()
	if pierce_timer:
		pierce_timer.stop()
