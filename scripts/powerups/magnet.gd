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

func _on_timeout() -> void:
	snap_items_to_grid()
	super._on_timeout()

func snap_items_to_grid() -> void:
	if not game_manager:
		return
		
	var tile_size = 32.0
	var center_offset = 16.0
	
	for child in game_manager.get_children():
		if "can_pickup" in child and child.can_pickup:
			var grid_x = floor(child.position.x / tile_size)
			var grid_y = floor(child.position.y / tile_size)
			
			var snapped_pos = Vector2(
				(grid_x * tile_size) + center_offset,
				(grid_y * tile_size) + center_offset
			)
			child.position = snapped_pos

	var pickups = get_tree().get_nodes_in_group("pickups")
	for pickup in pickups:
		if is_instance_valid(pickup) and pickup != self:
			var grid_x = floor(pickup.position.x / tile_size)
			var grid_y = floor(pickup.position.y / tile_size)
			
			var snapped_pos = Vector2(
				(grid_x * tile_size) + center_offset,
				(grid_y * tile_size) + center_offset
			)
			pickup.position = snapped_pos
