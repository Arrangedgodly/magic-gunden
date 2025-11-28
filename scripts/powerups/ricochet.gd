extends Pickup
class_name RicochetPickup

func _ready() -> void:
	super._ready()
	type = PickupType.Ricochet

func activate(manager: PowerupManager) -> void:
	super.activate(manager)
	
	manager.register_ricochet_powerup(self)
	manager.powerup_activated.emit("Ricochet")

func get_powerup_name() -> String:
	return "Ricochet"

func should_projectile_ricochet() -> bool:
	return is_active

func get_max_bounces() -> int:
	return 2
