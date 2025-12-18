extends Pickup
class_name PoisonPickup

var poison_trail_scene = preload("res://scenes/effects/poison_trail.tscn")
var spawned_poison_positions: Array = []
var trail_manager: TrailManager
var game_manager: Node2D

func _ready() -> void:
	super._ready()
	type = PickupType.Poison

func activate(manager: PowerupManager) -> void:
	super.activate(manager)
	
	trail_manager = manager.trail_manager
	game_manager = manager.game_manager
	spawned_poison_positions.clear()
	
	manager.register_poison_powerup(self)
	manager.powerup_activated.emit("Poison")

func get_powerup_name() -> String:
	return "Poison"

func process_effect(_delta: float) -> void:
	if not is_active or not trail_manager:
		return
	
	if trail_manager.move_history.is_empty():
		return
	
	var latest_position = trail_manager.move_history.back()
	var local_trail_pos = game_manager.to_local(latest_position)
	
	var already_has_poison = false
	for existing_poison_pos in spawned_poison_positions:
		if local_trail_pos.distance_to(existing_poison_pos) < 16:
			already_has_poison = true
			break
	
	if not already_has_poison:
		var poison_instance = poison_trail_scene.instantiate()
		poison_instance.position = local_trail_pos
		game_manager.add_child(poison_instance)
		
		spawned_poison_positions.append(local_trail_pos)

func _on_timeout() -> void:
	spawned_poison_positions.clear()
	
	super._on_timeout()
