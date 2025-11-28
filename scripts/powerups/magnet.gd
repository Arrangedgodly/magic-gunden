extends Pickup
class_name MagnetPickup

const MAGNET_RADIUS = 160.0
const PULL_SPEED = 300.0

var player: CharacterBody2D
var game_manager: Node2D

func _ready() -> void:
	super._ready()
	type = PickupType.Magnet

func activate(manager: PowerupManager) -> void:
	super.activate(manager)
	
	player = manager.player
	game_manager = manager.game_manager
	
	manager.register_magnet_powerup(self)
	manager.powerup_activated.emit("Magnet")

func get_powerup_name() -> String:
	return "Magnet"

func process_effect(delta: float) -> void:
	if not is_active or not player:
		return
	
	for child in game_manager.get_children():
		if "can_pickup" in child and child.can_pickup:
			var dist = child.global_position.distance_to(player.global_position)
			if dist < MAGNET_RADIUS:
				child.global_position = child.global_position.move_toward(player.global_position, PULL_SPEED * delta)
	
	var pickups = get_tree().get_nodes_in_group("pickups")
	for pickup in pickups:
		if is_instance_valid(pickup):
			var dist = pickup.global_position.distance_to(player.global_position)
			if dist < MAGNET_RADIUS:
				pickup.global_position = pickup.global_position.move_toward(player.global_position, PULL_SPEED * delta)
